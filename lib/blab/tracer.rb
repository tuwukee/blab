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
      proc do |event, file, line, method_name, context, class_name, ru_maxss|
        next if file =~ FILE_NAME
        # TODO: add an option to skip C-calls
        # TODO: add an option to loop only through the original method context
        next if C_CALLS.include?(event)

        time = Time.now.strftime(datetime_format)

        context.local_variables.each do |v|
          if context.local_variable_defined?(v)
            val = context.local_variable_get(v)
            old_v = defined_vars[v]
            if val != old_v
              formatted_output(v, val)
              defined_vars[v] = val
            end
          end
        end

        printer.print(
          time: time,
          event: event,
          file: file,
          line: line,
          method_name: method_name.to_s,
          class_name: class_name.to_s,
          # ru_maxss is in bytes on Mac OS X (Darwin), but in kilobytes on BSD and Linux
          ru_maxss: ru_maxss.to_s
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

    # TODO: DI
    def formatted_output(key, val)
      logger.info("Var......... #{key}=#{Blab::Formatter.format(val)}")
    end

    def defined_vars
      @defined_vars ||= {}
    end
  end
end
