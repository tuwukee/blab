# frozen_string_literal: true

require "minitest/autorun"
require "blab"

class TestPrinter < Minitest::Test
  def setup
    @logger = Blab::Config.logger
    @config = [
      [:time, 12],
      [:event, 6],
      [:file_lines, 50],
      [:class_name, 12],
      [:method_name, 12],
      [:ru_maxss, 12],
      [:code_lines, 120]
    ]
    @printer = Blab::Printer.new(@config, @logger)
  end

  def test_file_lines
    options = {
      file: "/test/file.rb",
      line: 10
    }
    expected = [["/test/file.rb:10"], Blab::Printer::DEFAULT_FILE_LINES_WIDTH]
    assert_equal @printer.file_lines(options), expected
  end

  def test_extra_file_lines
    options = {
      file: "/some/pretty/long/path/to/test/file.rb",
      line: 10,
      width: 5
    }
    expected = [
      ["/some", "/pret", "ty/lo", "ng/pa", "th/to", "/test", "/file", ".rb:1", "0"],
      options[:width]
    ]
    assert_equal @printer.file_lines(options), expected
  end

  def test_method_name
    options = {
      method_name: "secret",
      width: 15
    }
    expected = [[options[:method_name]], options[:width]]
    assert_equal @printer.method_name(options), expected
  end

  def test_event
    options = { event: "line" }
    expected = [[options[:event]], Blab::Printer::DEFAULT_EVENT_WIDTH]
    assert_equal @printer.event(options), expected
  end
end
