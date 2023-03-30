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
        "user_role" => "USR",
        "ai_role" => "GPT",
        "system_role" => "SYS"
      },
      "shell" => {
        "save_shell_history" => true,
        "enable_chat_context" => true,
        "show_welcome_info" => true,
        "shell_history_file" => "~/.richat/history.txt"
      },
      "prompt" => {
        "prompt_dir" => "~/.richat/prompts",
        "default" => ""
      }
    }.freeze

    class << self
      attr_reader :config

      def get(*keys)
        (@config ||= merge_config).dig(*keys)
      end
    end

    private

    def self.merge_config
      user_config = if File.exist?((config_file = File.expand_path("~/.richat/config.json")))
                      JSON.parse(File.read(config_file))
                    else
                      {}
                    end
      DEFAULT_CONFIG.deep_merge(user_config)
    end
  end
end