require 'csv'
require_relative 'enrollment'

class EnrollmentRepository
attr_reader :enrollments

  def initialize
    @enrollments = {}
  end

  def load_file(data)
    data.each do |key, file|
      extract_data(CSV.open(file, headers: true, header_converters: :symbol), key)
    end
  end

  def load_data(district_data)
    load_file(district_data[:enrollment])
  end


  def extract_data(data, grade_level)
    data.each do |row|
      name = row[:location]
      year = row[:timeframe]
      data = row[:data]
      creates_enrollments(name, year, data, grade_level)
    end
  end

  def find_by_name(name)
     @enrollments[name.upcase]
  end

  def creates_enrollments(name, year, data, grade_level)
    if !@enrollments.has_key?(name.upcase)
      @enrollments[name.upcase] = Enrollment.new({:name => name})
    end
    if grade_level == :kindergarten
      @enrollments[name.upcase].add_yearly_data(year, data)
    else
      @enrollments[name.upcase].add_yearly_high_school(year, data)
    end
  end
end
