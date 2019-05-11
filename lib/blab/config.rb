# frozen_string_literal: true

require "logger"

module Blab
  module Config
    extend self

    DATETIME_FORMAT = "%H:%M:%S.%L"

    DEFAULT_OUTPUT = {
      time:        { order: 1, width: 12 },
      event:       { order: 2, width: 6 },
      file_lines:  { order: 3, width: 50 },
      class_name:  { order: 4, width: 5 },
      method_name: { order: 5, width: 5 },
      ru_maxss:    { order: 6, width: 10 },
      code_lines:  { order: 7, width: 100 },
    }.freeze

    attr_writer :logger, :datetime_format, :log_output, :trace_c_calls, :output_config

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

    def output_config
      (@output_order || DEFAULT_OUTPUT).sort { |(k, v)| -v[:order] }.map { |(k, v)| [k, v[:width]] }
    end

    def datetime_format
      @datetime_format ||= DATETIME_FORMAT
    end

    def trace_c_calls?
      @trace_c_calls ||= false
    end
  end
end
