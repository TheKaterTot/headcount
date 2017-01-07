require_relative "test_helper"
require "./lib/enrollment_repository"

class Enrollment_Repo_Test < Minitest::Test
  def setup
    @er = EnrollmentRepository.new
  end

  def test_district_repo_exists
    assert_equal EnrollmentRepository, @er.class
  end

  def test_loads_data
    @er.load_data({
      :enrollment => {
        :kindergarten => "test/fixtures/kindergarten_sample.csv",
        :high_school_graduation => "test/fixtures/high_school_graduation_rates.csv"
      }
      })
    enrollment_1 = @er.find_by_name("ACADEMY 20")
    enrollment_2 = @er.find_by_name("AGATE 300")

    assert_equal "ACADEMY 20", enrollment_1.name
    assert_equal "AGATE 300", enrollment_2.name
  end

  def test_find_by_name_is_case_insensitive
    @er.load_data({
      :enrollment => {
        :kindergarten => "test/fixtures/kindergarten_sample.csv"
      }
      })
    enrollment_1 = @er.find_by_name("academy 20")

    assert_equal "ACADEMY 20", enrollment_1.name
  end

  def test_returns_nil_if_name_does_not_exist
    @er.load_data({
      :enrollment => {
        :kindergarten => "test/fixtures/kindergarten_sample.csv"
      }
      })

    enrollment_1 = @er.find_by_name("nope")

    assert_nil enrollment_1
  end
end
