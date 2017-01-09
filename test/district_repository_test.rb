require_relative "test_helper"
require "./lib/district_repository"

class District_Repo_Test < Minitest::Test
  def setup
    @dr = DistrictRepository.new
    @district = District.new(:name => "NOWHERE")
  end

  def test_district_repo_exists
    assert_equal DistrictRepository, @dr.class
  end

  def test_attributes_is_empty
    assert @dr.districts.empty?
  end

  def test_repo_loads_file
    contents = @dr.load_file("test/fixtures/kindergarten_sample.csv")

    assert contents.shift
  end

  def test_loads_data
    @dr.load_data({
      :enrollment => {
        :kindergarten => "test/fixtures/kindergarten_sample.csv"
      }
      })
    district_1 = @dr.find_by_name("ACADEMY 20")

    assert_equal "ACADEMY 20", district_1.name
  end

  def test_find_by_name_is_case_insensitive
    @dr.load_data({
      :enrollment => {
        :kindergarten => "test/fixtures/kindergarten_sample.csv"
      }
      })
    district_1 = @dr.find_by_name("academy 20")

    assert_equal "ACADEMY 20", district_1.name
  end

  def test_finds_matches
  @dr.load_data({
      :enrollment => {
        :kindergarten => "test/fixtures/kindergarten_sample.csv"
      }
      })

  assert_equal 2,  @dr.find_all_matching("bri").count
  end

  def test_makes_enrollment_repo
    @dr.load_data({
        :enrollment => {
          :kindergarten => "test/fixtures/kindergarten_sample.csv"
        }
        })

  district = @dr.find_by_name("ACADEMY 20")

  assert_equal 0.436, district.enrollment.kindergarten_participation_in_year(2010)
  end

  def test_loads_statewide_test_data
    @dr.load_data({
      :enrollment => {
        :kindergarten => "./data/Kindergartners in full-day program.csv",
        :high_school_graduation => "./data/High school graduation rates.csv",
      },
      :statewide_testing => {
        :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
        :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
        :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
        :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
        :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
      }
      })
      district = @dr.find_by_name("ACADEMY 20")

      assert district.statewide_test.check_race_validity(:asian)
    end
 end
