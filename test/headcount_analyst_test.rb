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
end
