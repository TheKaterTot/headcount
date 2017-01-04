require "csv"
require_relative "district"


class DistrictRepository

  def initialize
    @attributes = {}
  end

  def load_file(data)
    CSV.open data, headers: true, header_converters: :symbol
  end

  def load_data(district_data)
    contents = load_file(district_data[:enrollment][:kindergarten])
    districts = contents.map do |row|
      District.new({:name => row[:location]})
    end
    @attributes = districts.group_by do |row|
      row.name
    end
    #require 'pry'; binding.pry
    # @attributes = contents.group_by do |row|
    #   District.new({:name => row[:location]})
    #   require 'pry'; binding.pry

  end

  def find_by_name(name)
    name = name.upcase
    result = @attributes.fetch(name, nil)
    result[0]
  end

  def find_all_matching(fragment)
    matches = []
    fragment = fragment.upcase
    @attributes.each do |district|
      if  district[0].include?(fragment)
      matches << district[0]
#binding.pry
      end
    end
    matches
  end
end
