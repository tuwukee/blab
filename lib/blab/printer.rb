# frozen_string_literal: true

class Printer
  DEFAULT_CLASS_NAME_WIDTH = 10
  DEFAULT_CODE_LINES_WIDTH = 120
  DEFAULT_EVENT_WIDTH = 6
  DEFAULT_FILE_LINES_WIDTH = 60
  DEFAULT_RU_MAXSS_WIDTH = 50
  DEFAULT_METHOD_NAME_WIDTH = 10
  DEFAULT_TIME_WIDTH = 12

  PRINT_FIELDS = [
    :class_name,
    :code_lines,
    :event,
    :method_name,
    :time
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
    final = strings.map { |e| e.first.length }.max.times.map do |i|
      config.length.times.map do |j|
        (strings[j][0][i] || "").ljust(strings[j][1])
      end.join(" ")
    end
    logger.info final.join("\n")
  end

  def file_lines(options = {})
    file  = options[:file]
    line  = options[:line]
    width = options[:width] || DEFAULT_FILE_LINES_WIDTH
    ["#{file}:#{line}".scan(/.{#{width}}|.+/), width]
  end

  PRINT_FIELDS.each do |name|
    define_method(name) do |options = {}|
      val   = options[name]
      width = options[:width] || const_get("DEFAULT_#{name.upcase}_WIDTH")
      [val.scan(/.{#{width}}|.+/), width]
    end
  end

  def ru_maxss(options = {})
    val = options[:ru_maxss].to_s
    width = options[:width] || DEFAULT_MAX_RSS_WIDTH
    [val.scan(/.{#{width}}|.+/), width]
  end
end
