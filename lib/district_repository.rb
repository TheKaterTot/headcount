require "csv"
require_relative "district"
require_relative "enrollment_repository"


class DistrictRepository
  attr_reader :districts, :enrollment

  def initialize
    @districts = {}
    @er = EnrollmentRepository.new
  end

  def load_file(data)
    CSV.open data, headers: true, header_converters: :symbol
  end

  def load_data(district_data)
    @er.load_data(district_data)
    contents = load_file(district_data[:enrollment][:kindergarten])
    contents.each do |row|
      name = row[:location]
      @districts[name.upcase] = District.new({:name => name, :enrollment => @er.find_by_name(name)})
    end
  end

  def find_by_name(name)
    name = name.upcase
    @districts[name]
  end

  def find_all_matching(fragment)
    @districts.select {|key, value| key.include?(fragment.upcase)}
  end

end
