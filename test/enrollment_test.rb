require_relative "test_helper"
require "./lib/enrollment"

class DistrictTest < Minitest::Test

  def test_does_district_it_have_a_name
    e = Enrollment.new({:name => "Academy 20", :kindergarten_participation => {2010 => 1}} )
    assert_equal "ACADEMY 20", e.name
  end
end