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
end
