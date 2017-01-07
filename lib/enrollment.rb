require_relative "../../headcount/lib/cleanup"

class Enrollment
  include Cleanup
  attr_reader :name

  def initialize(attributes)
    @attributes = attributes
    @name = attributes[:name].upcase
    @attributes[:kindergarten_participation] ||= {}
    @attributes[:high_school_graduation] ||= {}
  end

  def add_yearly_data(year, data)
    @attributes[:kindergarten_participation][year] = data
  end

  def add_yearly_high_school(year, data)
    @attributes[:high_school_graduation][year] = data
  end

  def kindergarten_participation_by_year
    sanitize(@attributes[:kindergarten_participation])
  end

  def kindergarten_participation_in_year(year)
    data = sanitize(@attributes[:kindergarten_participation])
    data[year]
  end

  def graduation_rate_by_year
    sanitize(@attributes[:high_school_graduation])
  end

  def graduation_rate_in_year(year)
    data = sanitize(@attributes[:high_school_graduation])
    data[year]
  end
end
