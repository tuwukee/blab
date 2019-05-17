# frozen_string_literal: true

require "minitest/autorun"
require "blab"

class TestFormatter < Minitest::Test
  def setup
    @formatter = Blab::Formatter.new(15)
  end

  def test_array_formet
    arr1 = Array.new(3, 5)
    arr2 = Array.new(100, 10)

    assert_equal @formatter.format(arr1), "[5, 5, 5]"
    assert_equal @formatter.format(arr2), "[10, 10,... 10, 10]"
  end

  def test_string_format
    str1 = "test"
    str2 = str1 * 50

    assert_equal @formatter.format(str1), "\"test\""
    assert_equal @formatter.format(str2), "\"testtes...esttest\""
  end

  def test_hash_format
    hsh1 = { a: :b }
    hsh2 = { aaa: :bbbbb, dddd: :ccccccccccc, e: :f }

    assert_equal @formatter.format(hsh1), "{:a=>:b}"
    assert_equal @formatter.format(hsh2), "{:aaa=>:... :e=>:f}"
  end

  def test_struct_format
    person = Struct.new(:name, :age).new("Hanna", 30)

    assert_equal @formatter.format(person), "#<struct... age=30>"
  end
end
