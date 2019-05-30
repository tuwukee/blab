# frozen_string_literal: true

require "logger"

module Blab
  module Config
    extend self

    DATETIME_FORMAT = "%H:%M:%S.%L"

    DEFAULT_OUTPUT = [
      { type: :time, order: 1, width: 12 },
      { type: :event, order: 2, width: 6 },
      { type: :file_lines, order: 3, width: 50 },
      #{ type: :class_name, order: 4, width: 10 },
      #{ type: :method_name, order: 5, width: 12 },
      { type: :code_lines, order: 5, width: 120 }
    ].freeze

    attr_writer :logger,
                :datetime_format,
                :log_output,
                :trace_c_calls,
                :output_config,
                :output_order,
                :original_scope_only

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
      @output_config ||= (@output_order || DEFAULT_OUTPUT).sort_by { |h| h[:order] }.map! { |h| [h[:type], h[:width]] }
    end

    def datetime_format
      @datetime_format ||= DATETIME_FORMAT
    end

    def trace_c_calls?
      @trace_c_calls ||= false
    end

    def original_scope_only?
      @original_scope_only ||= false
    end
  end
end
