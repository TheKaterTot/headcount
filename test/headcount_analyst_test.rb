require_relative "test_helper"
require_relative "../../headcount/lib/district_repository"
require_relative "../../headcount/lib/headcount_analyst"

class HeadcountAnalystTest < Minitest::Test

  def setup
    @dr = DistrictRepository.new
    @dr.load_data({
      :enrollment => {
        :kindergarten => "./data/Kindergartners in full-day program.csv",
        :high_school_graduation => "./data/High school graduation rates.csv"
      },
      :statewide_testing => {
      :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
      :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
      :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
      :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
      :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
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
    assert_equal 0.768, @ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')
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
  end

  def test_raises_insufficient_error
    assert_raises(InsufficientInformationError) do

    @ha.top_statewide_test_year_over_year_growth(subject: :math)
   end
  end

  def test_raises_unknown_error
    assert_raises(UnknownDataError) do
      @ha.top_statewide_test_year_over_year_growth(grade: "9")
    end
  end

  def test_statewide_returns_top_district_for_grade
    #assert_equal "SANGRE DE CRISTO RE-22J", @ha.top_statewide_test_year_over_year_growth(grade: 3).first
    assert_equal "OURAY R-1", @ha.top_statewide_test_year_over_year_growth(grade: 8).first
    assert_in_delta 0.11, @ha.top_statewide_test_year_over_year_growth(grade: 8).last, 0.005
  end

  def test_statewide_returns_top_district_for_subject
    assert_equal "WILEY RE-13 JT", @ha.top_statewide_test_year_over_year_growth(grade: 3, subject: :math).first
    assert_in_delta 0.3, @ha.top_statewide_test_year_over_year_growth(grade: 3, subject: :math).last, 0.005
    assert_equal "COTOPAXI RE-3", @ha.top_statewide_test_year_over_year_growth(grade: 8, subject: :reading).first
    assert_in_delta 0.13, @ha.top_statewide_test_year_over_year_growth(grade: 8, subject: :reading).last, 0.005

    assert_equal "BETHUNE R-5", @ha.top_statewide_test_year_over_year_growth(grade: 3, subject: :writing).first
    assert_in_delta 0.148, @ha.top_statewide_test_year_over_year_growth(grade: 3, subject: :writing).last, 0.005
  end

  def test_returns_specific_number_of_results
    assert_equal "WILEY RE-13 JT", @ha.top_statewide_test_year_over_year_growth(grade: 3, top: 3, subject: :math).first.first
  end

  def test_returns_weighted_results
    top_performer = @ha.top_statewide_test_year_over_year_growth(grade: 8, :weighting => {:math => 0.5, :reading => 0.5, :writing => 0.0})
    assert_equal "OURAY R-1", top_performer.first
    assert_in_delta 0.153, top_performer.last, 0.005
  end
end
