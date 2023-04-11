require 'readline'

module Richat
  class Shell
    attr_reader :chat_client, :logger, :user_role, :ai_role, :system_role, :history_path

    def initialize(options = {})
      @chat_client = options[:chat_client]
      @logger = options[:logger]
      @user_role = Config.get("log", "user_role")
      @ai_role = Config.get("log", "ai_role")
      @system_role = Config.get("log", "system_role")
      @history_path = File.expand_path(Config.get("shell", "shell_history_file"))
      File.open(@history_path, 'w') {} unless File.exist?(@history_path)
    end

    def call
      enable_context_message = Config.get("shell", "enable_chat_context")
      enable_full_completion = Config.get("shell", "save_shell_history")

      if enable_full_completion
        Readline::HISTORY.push(*File.readlines(history_path).last(1000).map(&:chomp))
      end

      Readline.completion_proc = proc { |s| Readline::HISTORY&.grep(/^#{Regexp.escape(s)}/) }
      Readline.completion_append_character = ""

      default_prompt = Command.load_default_prompt
      if default_prompt.nil? || default_prompt.empty?
        context_messages = []
      else
        context_messages = [{ role: 'system', content: default_prompt }]
      end

      Command.print_welcome if Config.get("shell", "show_welcome_info")
      sys_cmd_mode = false

      begin
        while (user_content = Readline.readline(shell_prompt(sys_cmd_mode), true))
          if user_content.empty?
            Readline::HISTORY&.pop
            next
          end

          File.open(history_path, 'a') { |f| f.puts(user_content) } if enable_full_completion

          if (code = Command.call(user_content, sys_cmd_mode))
            if code == Command::NEXT_CODE
              next
            elsif code == Command::EXIT_CODE
              break
            elsif code == Command::PROMPT_CHANGED_CODE
              context_messages = [{ role: 'system', content: Command.prompt }]
              next
            elsif code == Command::SYS_CMD_CODE
              sys_cmd_mode = true
              next
            elsif code == Command::SYS_CHAT_CODE
              sys_cmd_mode = false
              next
            end
          end

          logger.call(role: user_role, content: user_content)
          response = ''

          context_messages << { role: 'user', content: user_content }

          chat_client.call(context_messages) do |chunk|
            response += chunk
            print chunk
          end

          if response.empty?
            Command.print_exception("Empty response from ChatGPT.")
            break
          end

          logger.call(role: ai_role, content: response)

          if enable_context_message
            context_messages << { role: 'assistant', content: response }
          else
            context_messages.pop
          end

          puts
        end
      rescue Interrupt
        if sys_cmd_mode
          Command.kill_process
          retry
        else
          Command.handle_exit
        end
      rescue SystemCallError => e
        puts e.message
        if sys_cmd_mode
          retry
        else
          Command.handle_exit
        end
      rescue Exception => e
        puts e.message
        Command.handle_exit
      end
    end

    private

    def shell_prompt(sys_cmd_mode)
      if sys_cmd_mode
        "\e[32m#{Command.prompt_id&.+" "}\e[0m\e[33m>>\e[0m \e[32m$ \e[0m"
      else
        "\e[32m#{Command.prompt_id&.+" "}\e[0m\e[33m>> \e[0m"
      end
    end
  end
end