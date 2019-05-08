# frozen_string_literal: true

require_relative "../ext/blab_trace"

module Blab
  def self.included(base)
    base.define_singleton_method(:blab) do |name|
      old_m = base.instance_method(name)
      base.send(:define_method, name) do |*args|
        puts "you have been decorated"
        puts old_m.source_location.inspect

        file, line_num = old_m.source_location
        lines = []

        # TODO: open file starting from the required line?
        File.open(file) do |f|
          current_line = 0
          f.each_line do |line|
            current_line += 1
            next if current_line < line_num

            # TODO: smart parser?
            lines << [current_line, line]
            break if line =~ /^end/
          end
        end

        puts lines

        puts RubyVM::InstructionSequence.disasm(old_m)
        puts "======================================="
        root = RubyVM::AbstractSyntaxTree.of(old_m)
        puts root.methods - Object.methods
        puts root
        puts "======================================"
        tree_lookup(root, "")
        puts "======================================="

  blab_trace proc { |event, file, line, id, binding, classname|
     printf "%8s %s:%-2d %10s %8s\n", event, file, line, id, classname
  }
        old_m.bind(self).call(*args)

        blab_trace nil
      end
    end
  end
end

def tree_lookup(node, padding)
  puts "#{padding}#{node.inspect}"
  return unless node.respond_to?(:children)
  puts "#{padding}children: #{node.children.size}"
  new_padding = "  #{padding}"
  node.children.each do |child|
    tree_lookup(child, new_padding)
  end
end

class Y
  include Blab

  blab def x(name, &block)
    a = 15
    puts(name)
  end
end

Y.new.x("test")
