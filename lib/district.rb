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

end
