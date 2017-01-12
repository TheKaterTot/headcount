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

  def do_some_math(min, max, number_of_subjects)
    min_year = min[1].reduce(0) { |memo, (key, value)| value + memo }
    max_year = max[1].reduce(0) { |memo, (key, value)| value + memo }
    ((max_year - min_year) / number_of_subjects) / (max[0] - min[0])
  end

  def math_weight(weighting, math)
     math.reduce({}) do |memo, (name, data)|
       memo[name] = (weighting[:math] * data)
       memo
     end
   end

   def reading_weight(weighting, reading)
     reading.reduce({}) do |memo, (name, data)|
       memo[name] = (weighting[:reading] * data)
       memo
     end
   end

   def writing_weight(weighting, writing)
     writing.reduce({}) do |memo, (name, data)|
       memo[name] = (weighting[:writing] * data)
       memo
     end
  end

  def weight(weighting, proficiency, subject)
    proficiency.reduce({}) do |memo, (name, data)|
      memo[name] = (weighting[subject] * data)
      memo
    end
  end

  def combine_weights(grade, weighting)
    math = weight(weighting, get_subject_info(grade, :math), :math)
    reading = weight(weighting, get_subject_info(grade, :reading), :reading)
    writing = weight(weighting, get_subject_info(grade, :writing), :writing)
    new_weight = math.merge(reading) do |key, oldval, newval|
      oldval + newval
    end
    combined_weight = new_weight.merge(writing) do |key, oldval, newval|
      truncates_float(oldval + newval)
    end
    weights = combined_weight.reduce({}) do |result, (name, data)|
      result[name] = data
      result
    end
    weights.sort_by { |key, value| value }.reverse
  end

  def data_valid?(data)
    results = data.all? do |subject, percent|
      !percent.is_a?(String)
    end
  end

  def get_info(grade)
    results = {}
    statewide.values.each do |district|
      grade_data = district.statewide_test.proficient_by_grade(grade)
      grade_data = grade_data.delete_if do |year, data|
        !data_valid?(data)
      end
      if grade_data.keys.count > 1
        min = grade_data.sort.first
        max = grade_data.sort.last
        data = truncates_float(do_some_math(min, max, 3.0))
        results[district.name] = data
      end
    end
    results.sort_by { |key, value| value }.reverse
  end

  def get_subject_info(grade, subject)
    results = {}
    statewide.values.each do |district|
      grade_data = district.statewide_test.proficient_by_grade(grade)
      subject_data = grade_data.reduce({}) do |memo, (year, data)|
        memo[year] = {subject => data[subject]}
        memo
      end
      subject_data = subject_data.delete_if do |year, data|
        !data_valid?(data)
      end
      if subject_data.keys.count > 1
        min = subject_data.sort.first
        max = subject_data.sort.last
        data = truncates_float(do_some_math(min, max, 1.0))
        results[district.name] = data
      end
    end
    results.sort_by { |key, value| value }.reverse
  end

  def top_statewide_test_year_over_year_growth(
    grade: nil, top: 0, weighting: {}, subject: :default)
    if grade.nil?
      raise InsufficientInformationError
    end
    grade = grade.to_i
    if grade != 3 && grade != 8
      raise UnknownDataError
    end
    if weighting.empty?
      if subject == :default
        get_info(grade).first
      elsif top == 0
        get_subject_info(grade, subject).first
      elsif top != 0
        get_subject_info(grade, subject).slice(0...top)
      end
    else
      combine_weights(grade, weighting).first
    end
  end
end
