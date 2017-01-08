require_relative "test_helper"
require_relative "../../headcount/lib/district_repository"
require "./lib/headcount_analyst"

class HeadcountAnalystTest < Minitest::Test

  def setup
    @dr = DistrictRepository.new
    @dr.load_data({
      :enrollment => {
        :kindergarten => "./data/Kindergartners in full-day program.csv",
        :high_school_graduation => "./data/High school graduation rates.csv"
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
  end

  def test_kindergarten_participation_against_high_school_graduation
    assert_in_delta 0.548, @ha.kindergarten_participation_against_high_school_graduation('MONTROSE COUNTY RE-1J'), 0.005
    assert_in_delta 0.800, @ha.kindergarten_participation_against_high_school_graduation('STEAMBOAT SPRINGS RE-2'), 0.005
  end

  def test_grade_graduation_correlation
    refute @ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'MONTROSE COUNTY RE-1J')
    assert @ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'ACADEMY 20')
  end

  def test_statewide_correlation
    refute @ha.kindergarten_participation_correlates_with_high_school_graduation(:for => 'STATEWIDE')
  end

  def test_district_correlation
    districts = ["ACADEMY 20", 'PARK (ESTES PARK) R-3', 'YUMA SCHOOL DISTRICT 1']
    assert @ha.kindergarten_participation_correlates_with_high_school_graduation(:across => districts)

  #   assert @ha.kindergarten_participation_correlates_with_high_school_graduation(
  # :across => ['district_1', 'district_2', 'district_3', 'district_4'])
  end

end
