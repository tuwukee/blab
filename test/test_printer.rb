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
end
