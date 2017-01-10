require_relative "test_helper"
require_relative "../../headcount/lib/economic_profile"
require_relative "../../headcount/lib/economic_profile_repository"

class EconomicProfileTest < Minitest::Test
  def setup
    @epr = EconomicProfileRepository.new
    @epr.load_data({
      :economic_profile => {
        :median_household_income => "./data/Median household income.csv",
        :children_in_poverty => "./data/School-aged children in poverty.csv",
        :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv",
        :title_i => "./data/Title I students.csv"
      }
      })
  end

  def test_economic_profile_has_name
    profile = EconomicProfile.new({:name => "ACADEMY 20"})
    assert_equal "ACADEMY 20", profile.name
  end

  def test_economic_profile_basics
    data = {:median_household_income => {[2014, "2015"] => 50000, [2013, 2014] => 60000},
            :children_in_poverty => {2012 => "0.1845"},
            :free_or_reduced_price_lunch => {2014 => {:percentage => 0.023, :total => 100}},
            :title_i => {2015 => 0.543},
           }
    ep = EconomicProfile.new(data)
    assert_equal 50000, ep.median_household_income_in_year(2015)
    assert_equal 55000, ep.median_household_income_in_year(2014)
    assert_equal 55000, ep.median_household_income_average
    assert_in_delta 0.184, ep.children_in_poverty_in_year(2012), 0.005

    assert_raises(UnknownDataError) do
      ep.children_in_poverty_in_year(9).class
    end

    assert_in_delta 0.023, ep.free_or_reduced_price_lunch_percentage_in_year(2014), 0.005
    assert_equal 100, ep.free_or_reduced_price_lunch_number_in_year(2014)
    assert_in_delta 0.543, ep.title_i_in_year(2015), 0.005
  end
end
