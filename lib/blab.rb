# frozen_string_literal: true

require_relative "../ext/blab_trace"
require_relative "blab/config"
require_relative "blab/printer"
require_relative "blab/tracer"

module Blab
  def self.included(base)
    base.define_singleton_method(:blab) do |name|
      old_m = base.instance_method(name)

      base.send(:define_method, name) do |*args|
        begin
          blab_trace(Blab::Tracer.trace)
          old_m.bind(self).call(*args)
        ensure
          blab_trace(nil)
          Blab::Tracer.reset
        end
      end
    end

    def with_blab
      begin
        blab_trace(Blab::Tracer.trace)
        yield
      ensure
        blab_trace(nil)
        Blab::Tracer.reset
      end
    end
  end
end
