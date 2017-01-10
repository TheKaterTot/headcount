require 'csv'
require_relative 'statewide_test'

class StatewideTestRepository

  def initialize
    @statewide_tests = {}
  end

  def load_file(data)
    data.each do |key, file|
      csv = CSV.open(file, headers: true, header_converters: :symbol)
      if [:third_grade, :eighth_grade].include?(key)
        extract_data_grades(csv, key)
      else
        extract_data_subjects(csv, key)
      end
    end
  end

  def load_data(district_data)
    if district_data.has_key?(:statewide_testing)
      load_file(district_data[:statewide_testing])
    end
  end


  def extract_data_grades(data, file_type)
    data.each do |row|
      name = row[:location]
      year = row[:timeframe]
      data = row[:data]
      subject = row[:score]
      creates_enrollments(name, file_type, subject, year, data)
    end
  end

  def extract_data_subjects(data, file_type)
    data.each do |row|
      name = row[:location]
      year = row[:timeframe]
      data = row[:data]
      ethnicity = row[:race_ethnicity]
      creates_enrollments(name, file_type, ethnicity, year, data)
    end
  end

  def find_by_name(name)
     @statewide_tests[name.upcase]
  end

  def creates_enrollments(name, file_type, info, year, data)
    if !@statewide_tests.has_key?(name.upcase)
      @statewide_tests[name.upcase] = StatewideTest.new({:name => name})
    end
    statewide_test = @statewide_tests[name.upcase]
    if file_type == :third_grade
      statewide_test.add_third_grade(info, year, data)
    elsif file_type == :eighth_grade
      statewide_test.add_eighth_grade(info, year, data)
    elsif file_type == :math
      statewide_test.add_math_data_for_race(info, year, data)
    elsif file_type == :writing
      statewide_test.add_writing_data_for_race(info, year, data)
    else
      statewide_test.add_reading_data_for_race(info, year, data)
    end
  end
end
