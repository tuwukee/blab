# frozen_string_literal: true

require 'set'

module Blab
  module Tracer
    FILE_NAME = /.+\/blab\.rb$/

    def self.trace(local_vars)
        # TODO: option to skip this
        files_map = Hash.new do |h, f|
          h[f] = File.readlines(f)
        end
        defined_vars = {}


      proc { |event, file, line, id, binding, classname|
          next if file =~ FILE_NAME

          # TODO: smart logger
          printf "%8s %s:%-2d %10s %8s %20s\n", event, file, line, id, classname, files_map[file][line - 1]

          local_vars.each do |v|
            if binding.local_variable_defined?(v)
              val = binding.local_variable_get(v)

              if defined_vars.key?(v)
                old_v = defined_vars[v]
                if val != old_v
                  puts "Var #{v} has changed from #{old_v} to #{val}"
                  defined_vars[v] = val
                end
              else
                puts "New var #{v}=#{val}"
                defined_vars[v] = val
              end
            end
          end
          #puts defined_vars.inspect
        }
    end
  end
end
