require_relative 'district_repository'
require_relative 'cleanup'
require_relative 'errors'

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

  def kindergarten_participation_against_high_school_graduation(
                                        name, options={against: "COLORADO"})
    (kindergarten_participation_rate_variation(name, options) /
    high_school_graduation_rate_variation(name, options))
  end

  def statewide
    @dr.districts.select do |name, district|
      name != "COLORADO"
    end
  end

  def correlation_results(district_names)
    state_data = district_names.map do |name|
        check_for_correlation(name)
      end
      total = state_data.length.to_f
      results = state_data.count(true).to_f
      results / total >= 0.70
  end

  def kindergarten_participation_correlates_with_high_school_graduation(options)
    if options[:for] == "STATEWIDE"
      correlation_results(statewide.keys)
    elsif options.has_key?(:across)
      correlation_results(options[:across])
    else
      check_for_correlation(options[:for])
    end
  end

  def check_for_correlation(name)
    kindergarten_participation_against_high_school_graduation(name) >= 0.6 &&
    kindergarten_participation_against_high_school_graduation(name) <= 1.5
  end

  def do_some_math(min, max)
    min_year = min[1].reduce(0) do |memo, (key, value)|
      if !value.is_a?(String)
        memo += value
      end
      memo
    end
    max_year = max[1].reduce(0) do |memo, (key, value)|
      if value.is_a?(Float)
        memo += value
      end
      memo
    end
     x = ((max_year - min_year) / 3) / (max[0] - min[0])
  end

  def data_valid?(data)
    results = data.map do |subject, percent|
      #require "pry"; binding.pry
        if percent.is_a?(String)
          false
        else
          true
        end
      end
    return false if results.include?(false)
  end

   def get_info(grade, subject)
     results = {}
     statewide.values.map do |district|
       statewide_test = district.attributes[:statewide_tests]
       info = {}
       info[district.name] = statewide_test.attributes[:third_grade]
       x = statewide_test.proficient_by_grade(grade)
       y = x.delete_if do |year, data|
        !data_valid?(data)
      end
      require "pry"; binding.pry
      min = y.sort.first
      max = y.sort.last
      data = truncates_float(do_some_math(min, max))
      results[district.name] = data
     end
     results.sort_by { |key, value| value }.reverse
   end

  def top_statewide_year_over_year_growth(grade: 0, subject: :default)
    if grade == 0
      raise InsufficientInformationError
    end
    grade = grade.to_i
    if grade != 3 && grade != 8
      raise UnknownDataError
    end
    if grade == 3
      get_info(grade, subject)
    end
  end


end
