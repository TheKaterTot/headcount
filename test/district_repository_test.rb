require_relative "test_helper"
require "./lib/district_repository"

class District_Repo_Test < Minitest::Test
  def setup
    @dr = DistrictRepository.new
  end

  def test_district_repo_exists
    assert_equal DistrictRepository, @dr.class
  end

  def test_repo_loads_file
    contents = @dr.load_file("test/fixtures/kindergarten_sample.csv")

    assert contents.shift
  end
end
