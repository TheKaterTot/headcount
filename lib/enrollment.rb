require "pry"
class Enrollment
attr_reader :name

  def initialize(attributes)
    @name = attributes[:name].upcase
  end
end
