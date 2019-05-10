# frozen_string_literal: true

require "logger"

module Blab
  module Config
    extend self

    DATETIME_FORMAT = "%H:%M:%S.%L"

    attr_writer :logger, :datetime_format, :log_output

    def logger
      @logger ||= begin
        logger = Logger.new(log_output)
        logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
        logger
      end
    end

    def log_output
      @log_output ||= STDOUT
    end

    def datetime_format
      @datetime_format ||= DATETIME_FORMAT
    end
  end
end
