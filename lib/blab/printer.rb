# frozen_string_literal: true

class Printer
  DEFAULT_CLASS_NAME_WIDTH = 5
  DEFAULT_CODE_LINES_WIDTH = 120
  DEFAULT_EVENT_WIDTH = 6
  DEFAULT_FILE_LINES_WIDTH = 60
  DEFAULT_RU_MAXSS_WIDTH = 50
  DEFAULT_METHOD_NAME_WIDTH = 10
  DEFAULT_TIME_WIDTH = 12

  PRINT_FIELDS = [
    :class_name,
    :event,
    :method_name,
    :time,
    :ru_maxss
  ].freeze

  attr_reader :config, :logger

  def initialize(config, logger)
    @config = config
    @logger = logger
  end

  def print(options = {})
    strings = config.map do |(type, width)|
      send(type, options.merge(width: width))
    end
    # TODO: do not ljust the last element
    final = strings.map { |e| e.first.length }.max.times.map do |i|
      config.length.times.map do |j|
        (strings[j][0][i] || "").ljust(strings[j][1])
      end.join(" ")
    end
    logger.info(final.join("\n"))
  end

  def file_lines(options = {})
    file  = options[:file]
    line  = options[:line]
    width = options[:width] || DEFAULT_FILE_LINES_WIDTH
    ["#{file}:#{line}".scan(/.{#{width}}|.+/), width]
  end

  def code_lines(options= {})
    file  = options[:file]
    line  = options[:line]
    width = options[:width] || DEFAULT_CODE_LINES_WIDTH
    [source_line(file, line).scan(/.{#{width}}|.+/), width]
  end

  PRINT_FIELDS.each do |name|
    define_method(name) do |options = {}|
      val   = options[name]
      width = options[:width] || const_get("DEFAULT_#{name.upcase}_WIDTH")
      [val.scan(/.{#{width}}|.+/), width]
    end
  end

  def reset_files
    @files_map && @files_map.keys.each { |key| @files_map.delete(key) }
  end

  def files_map
    @files_map ||= Hash.new do |h, f|
      h[f] = File.readlines(f)
    end
  end

  # TODO: show all relevant file-lines
  def source_line(file, line)
    begin
      files_map[file][line - 1]
    rescue
      "source is unavailable"
    end
  end
end
