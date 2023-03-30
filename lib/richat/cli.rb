module Richat
  class Cli
    attr_reader :chat_client, :logger, :user_content

    def initialize(options = {})
      @chat_client = options[:chat_client]
      @logger = options[:logger]
      @user_content = options[:user_content]
    end

    def call
      logger.call(role: Config.get("log", "user_role"), content: user_content)
      response = chat_client.call([{ role: 'user', content: user_content }])

      if !response.nil? && !response.empty?
        logger.call(role: Config.get("log", "ai_role"), content: response)
        puts response
      end
    end
  end
end