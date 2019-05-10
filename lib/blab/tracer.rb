# frozen_string_literal: true

module Blab
  module Tracer
    extend self

    FILE_NAME = /.+\/blab\.rb$/
    C_CALLS = ["c-call", "c-return"].freeze

    # TODO: skip this?
    def files_map
      @files_map ||= Hash.new do |h, f|
        h[f] = File.readlines(f)
      end
    end

    def defined_vars
      @defined_vars ||= {}
    end

    def reset
      @files_map && @files_map.keys.each { |key| @files_map.delete(key) }
      @defined_vars = {}
    end

    def source_line(file, line)
      begin
        files_map[file][line - 1]
      rescue
        nil
      end
    end

    def trace(local_vars, logger: Blab::Config.logger, datetime_format: Blab::Config.datetime_format)
      proc { |event, file, line, id, binding, classname|
          next if file =~ FILE_NAME
          # TODO: add option to skip C-calls
          # TODO: add option to loop only through the original method
          # TODO: add option to loop only through the original class?
          next if C_CALLS.include?(event)

          time = Time.now.strftime(datetime_format)

          #terminal_width = `tput cols`.to_i
          #cols = 6
          #col_width = (terminal_width / cols) - 1

          # TODO: smart logger


          local_vars.each do |v|
            if binding.local_variable_defined?(v)
              val = binding.local_variable_get(v)

                old_v = defined_vars[v]
                if val != old_v
                  logger.info("Var #{v}=#{val}")
                  defined_vars[v] = val
                end

            end
          end
          #printf "%8s %s:%-2d %10s %8s %20s\n", event, file, line, id, classname, source_line(file, line)

          #logger.info [event, file, line, id, classname].map{ |cell| cell.to_s.ljust(col_width) }.join(' ')
          #table = Terminal::Table.new(rows: [[event, "#{file}:#{line}", id, classname, source_line(file, line)]], style: { border_x: "", border_i: "" })

          file_lines = "#{file}:#{line}".scan(/.{#{40}}|.+/)
          code_lines = source_line(file, line).scan(/.{#{120}}|.+/)

          final = []
          max = [file_lines.size, code_lines.size].max - 1
          final << [time, event.ljust(7), file_lines[0].ljust(40), classname, code_lines[0].ljust(120)].join(" ")

          max.times do |i|
            final << [" ".ljust(12), " ".ljust(7), (file_lines[i+1] || " ").ljust(40), " "*classname.to_s.size, (code_lines[i+1] || " ").ljust(120)].join(" ")
          end

          logger.info(final.join("\n"))
          #puts defined_vars.inspect
        }
    end
  end
end
