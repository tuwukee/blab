# frozen_string_literal: true

module Blab
  class Formatter
    ELLIPSIS = "..."
    DEFAULT_MAX_LENGTH = 100

    attr_reader :max_length

    def initialize(max_length = DEFAULT_MAX_LENGTH)
      @max_length = max_length
    end

    def format(object)
      formatted = prepare_for_inspection(object).inspect
      return formatted if formatted.length < max_length

      beginning = truncate(formatted, 0, max_length / 2)
      ending = truncate(formatted, -max_length / 2, -1)
      "#{beginning}#{ELLIPSIS}#{ending}"
    end

    def prepare_for_inspection(object)
      case object
      when Array
        prepare_array(object)
      when Hash
        prepare_hash(object)
      else
        object
      end
    end

    def prepare_array(array)
      array.map { |element| prepare_for_inspection(element) }
    end

    def prepare_hash(input_hash)
      input_hash.inject({}) do |output_hash, key_and_value|
        key, value = key_and_value.map { |element| prepare_for_inspection(element) }
        output_hash[key] = value
        output_hash
      end
    end

    private

    def truncate(str, start_ind, end_ind)
      str[start_ind..end_ind].sub(/\e\[\d+$/, '')
    end
  end
end
