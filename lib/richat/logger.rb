require 'logger'

module Richat
  class Logger
    attr_reader :logger

    def initialize(options = {})
      original_log_header = ::Logger::LogDevice.instance_method(:add_log_header)
      ::Logger::LogDevice.send(:define_method, :add_log_header) { |_file| nil }

      @logger = ::Logger.new(options[:log_file])
      ::Logger::LogDevice.send(:define_method, original_log_header.name, original_log_header)

      @logger.formatter = proc do |_severity, datetime, role, msg|
        "[#{role}] #{datetime.strftime('%Y-%m-%d %H:%M:%S')}\n\n#{msg}\n\n"
      end
    end

    def call(log_data)
      logger.info(log_data[:role]) { log_data[:content] }
    end

    class << self
      def empty_logger
        ->() {}
      end
    end
  end
end