# frozen_string_literal: true
require_relative "blab"
require "set"

class Y
  include Blab

  blab def x(name, &block)
    a = 15
    b = 30
    puts(name)
    z(2)
    se = Set.new
  end

  def z(n)
    7 + n
  end
end

Y.new.x("test")
