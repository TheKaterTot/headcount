require "csv"
require_relative "../../headcount/lib/economic_profile"

class EconomicProfileRepository

  def initialize
    @economic_profiles = {}
  end

  def load_file(data)
    data.each do |key, file|
      if [:free_or_reduced_price_lunch].include?(key)
        extract_data_lunch(CSV.open(file, headers: true, header_converters: :symbol), key)
      else
        extract_data(CSV.open(file, headers: true, header_converters: :symbol), key)
      end
    end
  end

  def load_data(district_data)
    if district_data.has_key?(:economic_profile)
      load_file(district_data[:economic_profile])
    end
  end

  def extract_data(data, file_type)
    data.each do |row|
      name = row[:location]
      year = row[:timeframe]
      data = row[:data]
      creates_economic_profiles(name, file_type, year, data)
    end
  end

  def extract_data_lunch(data, file_type)
    data.each do |row|
      name = row[:location]
      year = row[:timeframe]
      data = row[:data]
      poverty_level = row[:poverty_level]
      data_format = row[:dataformat]
      creates_economic_profiles(name, file_type, year, data, poverty_level, data_format)
    end
  end

  def creates_economic_profiles(name, file_type, year, data, additional_info="", data_format = "")
    if !@economic_profiles.has_key?(name.upcase)
      @economic_profiles[name.upcase] = EconomicProfile.new({:name => name})
    end
    if file_type == :free_or_reduced_price_lunch
      @economic_profiles[name.upcase].add_lunch_data(year, data, additional_info, data_format)
    else
      @economic_profiles[name.upcase].add_data(year, data, file_type)
    end
  end

  def find_by_name(name)
    @economic_profiles[name.upcase]
  end

end
