# frozen_string_literal: true
require_relative "../../lib/blab"
require "set"

class Y
  include Blab

  blab def x(name, &block)
    a = 15
    b = 30
    d, c = 12, 67
    puts(name)
    yo = z(2)
    10.times do |i|
      a += i
      c = 8
    end
    se = Set.new
    hello(
      a,
      a,
      b
    )
    hsh = {
      xx: 1,
      a: 200,
      z: 300
    }
  end

  def z(n)
    7 + n
  end

  def hello(a, b, c)
    puts(a)
  end
end

Blab::Config.original_scope_only = true
Y.new.x("test")
