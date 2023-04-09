require 'json'

module Richat
  class Config
    DEFAULT_CONFIG = {
      "chatgpt" => {
        "api_key" => ENV["OPENAI_API_KEY"],
        "model" => "gpt-3.5-turbo",
        "temperature" => 0.7
      },
      "log" => {
        "enable" => true,
        "log_dir" => "~/.richat/logs",
        "log_file" => nil,
        "user_role" => "USR",
        "ai_role" => "GPT",
        "system_role" => "SYS"
      },
      "shell" => {
        "save_shell_history" => true,
        "enable_chat_context" => true,
        "show_welcome_info" => true,
        "shell_history_file" => "~/.richat/history.txt",
        "exit_keywords" => ["/exit", "q", "quit", "exit"]
      },
      "sys_cmd" => {
        "activate_keywords" => [">", "!"],
        "deactivate_keywords" => ["q", "quit", "exit"]
      },
      "prompt" => {
        "prompt_dir" => "~/.richat/prompts",
        "default" => ""
      }
    }.freeze

    class << self
      attr_reader :config

      def get_config
        (@config ||= merge_config)
      end

      def get(*keys)
        get_config.dig(*keys)
      end

      def override_with(other_config)
        @config = Utils.deep_merge_hash(get_config, other_config)
      end
    end

    private

    def self.merge_config
      user_config = if File.exist?((config_file = File.expand_path("~/.richat/config.json")))
                      JSON.parse(File.read(config_file))
                    else
                      {}
                    end
      Utils.deep_merge_hash(DEFAULT_CONFIG, user_config)
    end
  end
end