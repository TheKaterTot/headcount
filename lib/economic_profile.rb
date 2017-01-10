require_relative "cleanup"
require_relative "errors"

class EconomicProfile
  include Cleanup
  attr_reader :name

  def initialize(attributes)
    @attributes = {
      name: "",
      median_household_income: {},
      children_in_poverty: {},
      free_or_reduced_price_lunch: {},
      title_i: {}
    }.merge(attributes)
    @name = @attributes[:name].upcase
  end

  def add_lunch_data(year, data, additional_info, data_format)
    free_lunch = :free_or_reduced_price_lunch
    if !@attributes[free_lunch].has_key?(year)
      @attributes[free_lunch][year] = {}
    end
    if !@attributes[free_lunch][year].has_key?(additional_info)
      @attributes[free_lunch][year][additional_info] = {}
    end
    @attributes[free_lunch][year][additional_info][data_format] = data
  end

  def add_data(year, data, file_type)
    @attributes[file_type][year] = data
  end

  def median_household_income_in_year(year)
    clean_data = sanitize_hash_with_array(@attributes[:median_household_income])
    if !clean_data.keys.flatten.include?(year)
      raise UnknownDataError
    end
    count = 0
    clean_data.reduce(0) do |total, (years, income)|
      if years.include?(year)
        total += income
        count += 1
      end
      if !count.zero?
        total = total/count
      end
      total
    end
  end

  def median_household_income_average
    count = 0
    clean_data = sanitize_hash_with_array(@attributes[:median_household_income])
    clean_data.reduce(0) do |total, (years, income)|
      count += 1
      (total + income)/count
    end
  end

  def children_in_poverty_in_year(year)
    clean_data = sanitize(@attributes[:children_in_poverty])
    if !clean_data.keys.include?(year)
        raise UnknownDataError
    end
    clean_data[year]
  end

  def free_or_reduced_price_lunch_percentage_in_year(year)
    clean_data = sanitize_nested_hash(@attributes[:free_or_reduced_price_lunch])
    if !clean_data.keys.include?(year)
      raise UnknownDataError
    end
    clean_data[year][:percentage]
  end

  def free_or_reduced_price_lunch_number_in_year(year)
    clean_data = sanitize_nested_hash(@attributes[:free_or_reduced_price_lunch])
    if !clean_data.keys.include?(year)
      raise UnknownDataError
    end
    clean_data[year][:total]
  end

  def title_i_in_year(year)
    clean_data = sanitize(@attributes[:title_i])
    if !clean_data.keys.include?(year)
      raise UnknownDataError
    end
    clean_data[year]
  end
end
