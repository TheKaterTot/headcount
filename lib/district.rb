require_relative "district_repository"

class District
attr_reader :name, :attributes

  def initialize(attributes)
    @attributes = attributes
    @name = attributes[:name].upcase
  end

  def enrollment
    @attributes[:enrollment]
  end

  def statewide_test
    @attributes[:statewide_tests]
  end

  def economic_profile
    @attributes[:economic_profile]
  end
end
