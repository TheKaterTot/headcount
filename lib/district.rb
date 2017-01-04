class District
attr_reader :name

  def initialize(attributes)
    @name = attributes[:name].upcase
  end
end
