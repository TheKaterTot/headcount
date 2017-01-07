require_relative "test_helper"
require "./lib/enrollment"

class DistrictTest < Minitest::Test

  def test_does_district_it_have_a_name
    e = Enrollment.new({:name => "Academy 20", :kindergarten_participation => {"2010" => "1"}} )
    assert_equal "ACADEMY 20", e.name
  end

  def test_kindergarten_participation_by_year
    e = Enrollment.new({:name => "Academy 20", :kindergarten_participation => {"2010" => "0.1345"}} )
    assert_equal({2010 => 0.134}, e.kindergarten_participation_by_year)
  end

  def test_kindergarten_participation_by_year_with_multiple_years
    e = Enrollment.new({:name => "Academy 20", :kindergarten_participation => {"2010" => "0.1345", "2011" => "0.34567"}})
    assert_equal({2010 => 0.134, 2011 => 0.345}, e.kindergarten_participation_by_year)
  end

  def test_kindergarten_participation_in_year
    e = Enrollment.new({:name => "Academy 20", :kindergarten_participation => {"2010" => "0.1345", "2011" => "0.34567"}})
    assert_equal 0.134, e.kindergarten_participation_in_year(2010)
  end

  def test_kindergarten_participation_in_year_returns_nil
    e = Enrollment.new({:name => "Academy 20", :kindergarten_participation => {"2010" => "0.1345", "2011" => "0.34567"}})
    assert_nil e.kindergarten_participation_in_year(2004)
  end
end
