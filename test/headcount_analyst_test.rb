require_relative "test_helper"
require_relative "../../headcount/lib/district_repository"
require "./lib/headcount_analyst"

class HeadcountAnalystTest < Minitest::Test

  def setup
    @dr = DistrictRepository.new
    @dr.load_data({
      :enrollment => {
        :kindergarten => "./data/Kindergartners in full-day program.csv"
      }
      })
    @ha = HeadcountAnalyst.new(@dr)
  end

  def test_does_headcount_exist
    assert_instance_of HeadcountAnalyst, @ha
  end

  def test_average_returns_average
    numbers = {"one" => 0.357, "two" => 0.965, "three" => 0.123, "four" => 0.965}
    assert_in_delta 0.602, @ha.average(numbers.values), 0.005
  end

  def test_kindergarten_variation_rates
    assert_equal 0.766, @ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')
    assert_in_delta 0.447, @ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1'), 0.005
  end

  def test_kindergarten_rate_variation_trend
    trends = @ha.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')
    assert_in_delta 1.257, trends[2004], 0.005
    assert_in_delta 0.661, trends[2014], 0.005

    # => {2004 => 1.257, 2005 => 0.96, 2006 => 1.05, 2007 => 0.992, 2008 => 0.717, 2009 => 0.652, 2010 => 0.681, 2011 => 0.727, 2012 => 0.688, 2013 => 0.694, 2014 => 0.661 }
  end
end
