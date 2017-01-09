require_relative "district_repository"

class District
attr_reader :name

  def initialize(attributes)
    @attributes = attributes
    @name = attributes[:name].upcase
  end

  def enrollment
    @attributes[:enrollment]
  end

  def statewide_test
    #require "pry"; binding.pry
    @attributes[:statewide_tests]
  end

end
