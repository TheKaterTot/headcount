require_relative "test_helper"
require_relative "../../headcount/lib/economic_profile_repository"

class EconomicProfileRepositoryTest < Minitest::Test
  def setup
    @epr = EconomicProfileRepository.new
  end

  def test_economic_repo_exists
    assert_equal EconomicProfileRepository, @epr.class
  end

  def test_loads_data
    @epr.load_data({
      :economic_profile => {
        :median_household_income => "./data/Median household income.csv",
        :children_in_poverty => "./data/School-aged children in poverty.csv",
        :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv",
        :title_i => "./data/Title I students.csv"
      }
      })
      epr = @epr.find_by_name("ACADEMY 20")

      assert_equal "ACADEMY 20", epr.name
    end
  end
