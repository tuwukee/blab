# frozen_string_literal: true

require_relative "../ext/blab_trace"
require_relative "blab/config"
require_relative "blab/tracer"

module Blab
  def self.included(base)
    base.define_singleton_method(:blab) do |name|
      old_m = base.instance_method(name)

      base.send(:define_method, name) do |*args|
        begin
          root = RubyVM::AbstractSyntaxTree.of(old_m)
          local_vars = root.children.first
          blab_trace(Blab::Tracer.trace(local_vars))
          old_m.bind(self).call(*args)
        ensure
          blab_trace(nil)
        end
      end
    end

    # TODO: with_blab
  end
end
