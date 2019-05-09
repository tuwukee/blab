# frozen_string_literal: true

require "logger"

module Blab
  module Config
    extend self

    DATETIME_FORMAT = "%H:%M:%S.%L"

    attr_writer :logger, :datetime_format

    def logger
      @logger ||= begin
        logger = Logger.new(STDOUT)
        logger.formatter = proc do |severity, datetime, progname, msg|
          "#{datetime.strftime(datetime_format)}: #{msg}\n"
        end
        logger
      end
    end

    def datetime_format
      @datetime_format ||= DATETIME_FORMAT
    end
  end
end
