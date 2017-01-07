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
    truncates_float((find_district_data_average(name_1) /
    find_district_data_average(name_2[:against])))
  end

  def high_school_graduation_rate_variation(name_1, name_2)
    truncates_float((find_high_school_district_data_average(name_1) /
    find_high_school_district_data_average(name_2[:against])))
  end

  def kindergarten_participation_rate_variation_trend(name_1, name_2)
    data_1 = find_district_data(name_1)
    data_2 = find_district_data(name_2[:against])
    data_1.reduce({}) do |memo, (key, value)|
      memo[key] = truncates_float(data_1[key] / data_2[key])
      memo
    end
  end

  def find_district_data_average(name)
    average(find_district_data(name).values)
  end

  def find_high_school_district_data_average(name)
    average(find_high_school_district_data(name).values)
  end

  def find_district_data(name)
    find_enrollment(name).kindergarten_participation_by_year
  end

  def find_high_school_district_data(name)
    find_enrollment(name).graduation_rate_by_year
  end

  def find_enrollment(name)
    district = @dr.find_by_name(name)
    enrollment = district.enrollment
  end

  def kindergarten_participation_against_high_school_graduation(name, options={against: "COLORADO"})
    (kindergarten_participation_rate_variation(name, options) /
    high_school_graduation_rate_variation(name, options))
  end
end
