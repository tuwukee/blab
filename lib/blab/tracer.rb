# frozen_string_literal: true

module Blab
  module Tracer
    extend self

    FILE_NAME = /.+\/blab\.rb$/
    C_CALLS = ["c-call", "c-return"].freeze

    def reset
      @files_map && @files_map.keys.each { |key| @files_map.delete(key) }
      @defined_vars = {}
    end

    def trace
      proc do |event, file, line, method_name, context, class_name, ru_maxss|
        # ru_maxss is in bytes on Mac OS X (Darwin), but in kilobytes on BSD and Linux
        next if file =~ FILE_NAME
        # TODO: add option to skip C-calls
        # TODO: add option to loop only through the original method
        # TODO: add option to loop only through the original class?
        next if C_CALLS.include?(event)

        time = Time.now.strftime(datetime_format)

        context.local_variables.each do |v|
          if context.local_variable_defined?(v)
            val = context.local_variable_get(v)
            old_v = defined_vars[v]
            if val != old_v
              # TODO: what if the var is too big
              logger.info("Var......... #{v}=#{val}")
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
          code_lines: source_line(file, line),
          ru_maxss: ru_maxss
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

    def osx?
      (/darwin/ =~ RUBY_PLATFORM) != nil
    end

    def source_line(file, line)
      begin
        files_map[file][line - 1]
      rescue
        nil
      end
    end

    # TODO: skip this?
    # TODO: show all relevant file-lines?
    def files_map
      @files_map ||= Hash.new do |h, f|
        h[f] = File.readlines(f)
      end
    end

    def defined_vars
      @defined_vars ||= {}
    end
  end
end
