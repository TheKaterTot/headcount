require 'csv'
require_relative 'enrollment'

class EnrollmentRepository
attr_reader :enrollments 

  def initialize
    @enrollments = {}
  end

  def load_file(data)
    CSV.open data, headers: true, header_converters: :symbol
  end

  def load_data(district_data)
    contents = load_file(district_data[:enrollment][:kindergarten])
    contents.each do |row|
      name = row[:location]
      year = row[:timeframe]
      data = row[:data]
      @enrollments[name] = Enrollment.new({:name => name, 
                                           :kindergarten_participation => {year => data}})
    end
    end

  def find_by_name(name)
     @enrollments[name.upcase]
  end
end