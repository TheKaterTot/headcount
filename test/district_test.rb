require_relative "test_helper"
require "./lib/district"

class DistrictTest < Minitest::Test

  def test_does_district_have_a_name
    d = District.new(:name => "ACADEMY 20")
    assert_equal "ACADEMY 20", d.name
  end

  def test_district_repository_enrollment_relationship
    d = District.new(:name => "ACADEMY 20", :enrollment => "guess")
    assert_equal "guess", d.enrollment
  end
end
