# frozen_string_literal: true

require_relative "blab/config"
require_relative "blab/formatter"
require_relative "blab/printer"
require_relative "blab/tracer"
require_relative "blab/version"

module Blab
  def self.included(base)
    base.define_singleton_method(:blab) do |name|
      old_m = self.instance_method(name)

      base.send(:define_method, name) do |*args|
        begin
          set_trace_func(Blab::Tracer.trace)
          old_m.bind(self).call(*args)
        ensure
          set_trace_func(nil)
          Blab::Tracer.reset
        end
      end
    end

    def with_blab
      begin
        set_trace_func(Blab::Tracer.trace)
        yield
      ensure
        set_trace_func(nil)
        Blab::Tracer.reset
      end
    end
  end
end

BasicObject.include(Blab)
