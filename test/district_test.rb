require_relative "test_helper"
require "./lib/district"

class DistrictTest < Minitest::Test

  def test_does_district_it_have_a_name
    d = District.new(:name => "ACADEMY 20")
    assert_equal "ACADEMY 20", d.name
  end
end