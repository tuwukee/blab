# frozen_string_literal: true

require "minitest/autorun"
require "blab"

class SimpleTest
  def sum(a, b)
    with_blab { a + b }
  end

  blab def diff(a, b)
    a - b
  end
end

class TestBlab < Minitest::Test
  def setup
    @simple_test = SimpleTest.new
  end

  def test_sum
    out, err = capture_subprocess_io do
      @simple_test.sum(1, 2)
    end
    assert_equal err, ""
    assert_match(/with_blab { a \+ b }/, out)
  end

  def test_diff
    out, err = capture_subprocess_io do
      @simple_test.diff(2, 1)
    end
    assert_equal err, ""
    assert_match(/a - b/, out)
  end
end
