module Richat
  class Command
    EXIT_CODE = 0
    NEXT_CODE = 1
    PROMPT_CHANGED_CODE = 2
    SYS_CMD_CODE = 3
    SYS_CHAT_CODE = 4
    TOGGLE_CONTEXT_CODE = 5

    class << self
      attr_reader :prompt, :prompt_id

      def call(user_input, sys_cmd_mode)
        user_input = user_input.strip

        if sys_cmd_mode
          return SYS_CHAT_CODE if Config.get("sys_cmd", "deactivate_keywords").include?(user_input)
          handle_system_command(user_input)
        else
          return SYS_CMD_CODE if Config.get("sys_cmd", "activate_keywords").include?(user_input)
          return handle_exit if Config.get("shell", "exit_keywords").include?(user_input)
          return unless user_input.start_with?("/")
          if user_input == "/help"
            handle_help
          elsif user_input == "/config"
            handle_config
          elsif user_input =~ /^\/prompt\s*/
            if user_input == "/prompt"
              handle_prompt
            else
              handle_choose_prompt(user_input.split(" ").last)
            end
          elsif user_input == "/context"
            handle_toggle_context
          end
        end
      end

      def handle_system_command(cmd)
        if (match = /^cd\s?(.*)$/.match(cmd))
          fp = File.expand_path(match[1].empty? ? "~" : match[1])
          begin
            Dir.chdir(fp)
          rescue
            puts "cd: no such file or directory: #{fp}"
          end
        else
          @pid = Process.spawn(cmd)
          Process.wait(@pid)
        end

        NEXT_CODE
      end

      def handle_exit
        kill_process
        puts "Bye!"
        EXIT_CODE
      end

      def kill_process
        return if @pid.nil?
        if Gem.win_platform?
          system("taskkill /F /PID #{@pid}", err: File::NULL)
        else
          return unless process_exist?
          begin
            Process.kill("TERM", @pid)
          rescue
            nil
          end
        end
        @pid = nil
      end

      def process_exist?
        begin
          Process.getpgid(@pid)
          true
        rescue
          false
        end
      end

      def handle_config
        puts "\e[32mConfiguration file path is #{File.expand_path("~/.richat/config.json")}\e[0m"
        puts JSON.pretty_generate(Config.get_config)
        NEXT_CODE
      end

      def handle_toggle_context
        TOGGLE_CONTEXT_CODE
      end

      def handle_help
        puts "Version #{VERSION}"
        puts "\e[32m/exit\e[0m exit Richat"
        puts "\e[32m/config\e[0m show configuration"
        puts "\e[32m/prompt\e[0m show prompt list"
        puts "\e[32m/context\e[0m toggle chat context"
        puts "\e[32m/help\e[0m show help info"
        NEXT_CODE
      end

      def prompt_id_list
        Dir.entries(File.expand_path(Config.get("prompt", "prompt_dir"))).delete_if {|s| [".",".."].include?(s)}
      end

      def handle_prompt
        id_list = prompt_id_list
        if id_list.empty?
          print_exception "#{File.expand_path(Config.get("prompt", "prompt_dir"))} has no prompt files."
          return NEXT_CODE
        end

        if prompt.nil? || prompt.empty?
          puts "\e[32mCurrent prompt not set.\e[0m"
          puts "Use command \e[32m/prompt prompt_index\e[0m or \e[32m/prompt prompt_id\e[0m to set prompt."
        end

        id_list.each_with_index do |pt, idx|
          if pt == prompt_id
            puts "#{idx}. \e[32m#{pt}\e[0m"
          else
            puts "#{idx}. #{pt}"
          end
        end
        NEXT_CODE
      end

      def handle_choose_prompt(arg)
        id_list = prompt_id_list
        if id_list.empty?
          print_exception("Prompt files not found.")
          return NEXT_CODE
        end

        if id_list.include?(arg)
          current_prompt_id = arg
        elsif arg =~ /\d/
          pt_id = id_list[arg.to_i]
          if pt_id.nil?
            print_exception("Prompt not found.")
            return NEXT_CODE
          end
          current_prompt_id = pt_id
        else
          print_exception("Prompt not found.")
          return NEXT_CODE
        end

        if current_prompt_id == @prompt_id
          print_exception("Prompt not changed.")
          return NEXT_CODE
        end

        prompt_content = File.read(File.join(File.expand_path(Config.get("prompt", "prompt_dir")), current_prompt_id))
        if prompt_content.empty?
          print_exception("Prompt is empty.")
          return NEXT_CODE
        end

        puts "Changed prompt to #{current_prompt_id}."
        @prompt_id = current_prompt_id
        @prompt = prompt_content
        PROMPT_CHANGED_CODE
      end

      def print_exception(message)
        puts "\e[31m#{message}\e[0m"
      end

      def print_info(message)
        puts "\e[32m#{message}\e[0m"
      end

      def print_welcome
        puts "Richat is a command-line ChatGPT tool implemented in Ruby that supports highly customizable configuration, press \e[32m/help\e[0m to display help info. If you have any suggestions or questions, please feel free to provide feedback on https://github.com/fzdp/richat."
      end

      def load_default_prompt
        @prompt ||= begin
          @prompt_id = Config.get("prompt", "default")
          if @prompt_id.nil? || @prompt_id.empty?
            @prompt_id = nil
            return
          end

          begin
            File.read(File.join(File.expand_path(Config.get("prompt", "prompt_dir")), @prompt_id))
          rescue => e
            print_exception(e.message)
            exit
          end
        end
      end
    end
  end
end