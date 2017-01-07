require_relative '../../headcount/lib/district_repository'
require_relative '../../headcount/lib/cleanup'

class HeadcountAnalyst
  include Cleanup

  def initialize(dr)
    @dr = dr
  end

  def average(numbers)
    truncates_float((numbers.reduce(0) do |memo, number|
      memo += number
    end) / numbers.count)
  end

  def kindergarten_participation_rate_variation(name_1, name_2)
    truncates_float((find_district_data(name_1) /
    find_district_data(name_2[:against])))

  end

  def find_district_data(name)
    district = @dr.find_by_name(name)
    enrollment = district.enrollment
    district_numbers = enrollment.kindergarten_participation_by_year
    average(district_numbers.values)
  end
end
