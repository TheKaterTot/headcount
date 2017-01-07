require_relative "../../headcount/lib/cleanup"

class Enrollment
  include Cleanup
  attr_reader :name

  def initialize(attributes)
    @attributes = attributes
    @name = attributes[:name].upcase
  end

  def add_yearly_data(year, data)
    @attributes[:kindergarten_participation][year] = data
  end

  def kindergarten_participation_by_year
    sanitize(@attributes[:kindergarten_participation])
  end

  def kindergarten_participation_in_year(year)
    data = sanitize(@attributes[:kindergarten_participation])
    data[year]
  end
end
