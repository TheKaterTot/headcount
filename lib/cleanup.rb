module Cleanup
  def sanitize(data)
      clean_data = {}
      data.map do |key, value|
        clean_data[key.to_i] = truncates_float(value)
      end
    clean_data
  end

  def sanitize_nested_hash(data)
    clean_data = {}
    data.map do |key, values|
      clean_data[key.to_i] = values.reduce({}) do |memo, (subject, data)|
        memo[subject.downcase.to_sym] = truncates_float(data)
        if truncates_float(data).zero?
          memo[subject.downcase.to_sym] = "N/A"
        end
        memo
      end
    end
    clean_data
  end

  def sanitize_hash_with_array(data)
    clean_data = {}
    data.map do |key, value|
      clean_data[key.map(&:to_i)] = value.to_i
    end
    clean_data
  end

  def truncates_float(float)
    #require "pry"; binding.pry
    (float.to_f).round(3)
  end
end
