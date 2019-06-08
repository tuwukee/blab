# frozen_string_literal: true

module Blab
  module Tracer
    extend self

    FILE_NAME = /.+\/blab\.rb$/
    C_CALLS = ["c-call", "c-return"].freeze

    def reset
      printer.reset_files
      @defined_vars = {}
    end

    def trace
      proc do |event, file, line, method_name, context, class_name|
        next if file =~ FILE_NAME
        next if skip_c_calls? && C_CALLS.include?(event)
        next if original_scope_only? && !original_scope?(file, method_name, class_name)

        context.local_variables.each do |v|
          next unless context.local_variable_defined?(v)

          val = context.local_variable_get(v)
          old_v = defined_vars[v]

          next if val == old_v

          formatted_output(v, val)
          defined_vars[v] = val
        end

        printer.print(
          time: Time.now.strftime(datetime_format),
          event: event,
          file: file,
          line: line,
          method_name: method_name.to_s,
          class_name: class_name.to_s
        )
      end
    end

    private

    def printer
      @printer ||= Printer.new(Blab::Config.output_config, logger)
    end

    def logger
      Blab::Config.logger
    end

    def datetime_format
      Blab::Config.datetime_format
    end

    def formatted_output(key, val)
      logger.info("Var......... #{key}=#{formatter.format(val)}")
    end

    def formatter
      @formatter ||= Blab::Formatter.new
    end

    def defined_vars
      @defined_vars ||= {}
    end

    def original_scope_only?
      Blab::Config.original_scope_only?
    end

    def skip_c_calls?
      !Blab::Config.trace_c_calls?
    end

    def original_scope?(file, method_name, class_name)
      @original_file ||= file
      @original_method_name ||= method_name
      @orinal_class_name ||= class_name

      @original_file == file &&
        @original_method_name == method_name &&
        @orinal_class_name == class_name
    end
  end
end
