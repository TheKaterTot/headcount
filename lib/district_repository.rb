require "csv"
require_relative "district"


class DistrictRepository
  attr_reader :attributes

  def initialize
    @districts = {}
  end

  def load_file(data)
    CSV.open data, headers: true, header_converters: :symbol
  end

  def load_data(district_data)
    contents = load_file(district_data[:enrollment][:kindergarten])
    contents.each do |row|
      name = row[:location]
      @districts[name] = District.new({:name => name})
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
