require_relative "test_helper"
require "./lib/enrollment"

class DistrictTest < Minitest::Test

  def test_does_district_have_a_name
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

  def test_high_school_graduation_by_year
    e = Enrollment.new({:name => "Academy 20", :high_school_graduation => {"2010" => "0.895", "2011" => "0.895"}})
    assert_equal({2010 => 0.895, 2011 => 0.895}, e.graduation_rate_by_year)
  end

  def test_high_school_graduation_in_year
    e = Enrollment.new({:name => "Academy 20", :high_school_graduation => {"2010" => "0.895", "2011" => "0.895"}})
    assert_equal 0.895, e.graduation_rate_in_year(2011)
  end

end
