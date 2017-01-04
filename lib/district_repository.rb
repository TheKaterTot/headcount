require "csv"

class DistrictRepository

  def initialize

  end

  def load_file(data)
    CSV.open(data)
  end
end
