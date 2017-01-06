require "pry"
class Enrollment
  attr_reader :name

  def initialize(attributes)
    @attributes = attributes
    @name = attributes[:name].upcase
  end

  def add_yearly_data(year, data)
    @attributes[:kindergarten_participation][year] = data
  end


  def sanitize(data)
      data = @attributes[:kindergarten_participation]
      clean_data = {}
      data.map do |key, value|
        clean_data[key.to_i] = truncates_float(value)
      end
    clean_data
  end

  def truncates_float(float)
    (float.to_f - 0.0005).round(3)

  end

  def kindergarten_participation_by_year
    sanitize(@attributes[:kindergarten_participation])
  end

  def kindergarten_participation_in_year(year)
    data = sanitize(@attributes[:kindergarten_participation])
    data[year]
  end
end
