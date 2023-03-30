require 'faraday'

module Openai
  class Chat
    BASE_URL = 'https://api.openai.com'.freeze

    attr_reader :conn, :model, :temperature, :stream

    def initialize(options = {})
      @conn = Faraday.new(
        url: BASE_URL,
        headers: { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{options[:api_key]}" }
      )
      @model, @temperature, @stream = options.values_at(:model, :temperature, :stream)
    end

    def call(messages)
      res = conn.post('/v1/chat/completions') do |req|
        req.body = {
          model: model,
          temperature: temperature,
          messages: messages,
          stream: stream
        }.to_json

        if stream
          req.options.on_data = Proc.new do |chunk, overall_received_bytes, env|
            chunk_text = get_chunk_text(chunk)
            yield chunk_text unless chunk_text.nil?
          end
        end
      end

      JSON.parse(res.body).dig("choices", 0, "message", "content") unless stream
    end

    private

    def get_chunk_text(chunk)
      chunk_text = ''
      chunk.split("\n\n").map { |data_str| data_str.sub(/^(data: )/, '') }.each do |data_str|
        return nil if data_str == '[DONE]'
        chunk_text += JSON.parse(data_str).dig('choices', 0, 'delta', 'content') || ''
      end
      chunk_text
    end
  end
end