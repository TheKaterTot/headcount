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
        memo
      end
    end
    clean_data
  end

  def truncates_float(float)
    (float.to_f - 0.0005).round(3)
  end
end
