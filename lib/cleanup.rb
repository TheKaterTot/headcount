module Cleanup
  def sanitize(data)
      clean_data = {}
      data.map do |key, value|
        clean_data[key.to_i] = truncates_float(value)
      end
    clean_data
  end

  def truncates_float(float)
    (float.to_f - 0.0005).round(3)
  end
end
