require_relative "test_helper"
require_relative "../../headcount/lib/statewide_test"
require_relative "../../headcount/lib/statewide_test_repository"

class StatewideTestTest < Minitest::Test

  def setup
    @str = StatewideTestRepository.new
    @str.load_data({
      :statewide_testing => {
      :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
      :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
      :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
      :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
      :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
  }
})
  end

  def test_does_district_have_a_name
    st = StatewideTest.new({:name => "Academy 20"})
    assert_equal "ACADEMY 20", st.name
  end

  def test_proficient_by_grade
    expected = { 2008 => {:math => 0.857, :reading => 0.866, :writing => 0.671},
                 2009 => {:math => 0.824, :reading => 0.862, :writing => 0.706},
                 2010 => {:math => 0.849, :reading => 0.864, :writing => 0.662},
                 2011 => {:math => 0.819, :reading => 0.867, :writing => 0.678},
                 2012 => {:math => 0.830, :reading => 0.870, :writing => 0.655},
                 2013 => {:math => 0.855, :reading => 0.859, :writing => 0.668},
                 2014 => {:math => 0.834, :reading => 0.831, :writing => 0.639}
               }

    testing = @str.find_by_name("ACADEMY 20")
    expected.each do |year, data|
      data.each do |subject, proficiency|
        assert_in_delta proficiency, testing.proficient_by_grade(3)[year][subject], 0.005
      end
    end
  end

  def test_raises_unknown_error
    testing = @str.find_by_name("ACADEMY 20")

        assert_raises(UnknownDataError) do
          testing.proficient_by_grade(9)[year][subject].class
      end
  end

  def test_basic_proficiency_by_race
    testing = @str.find_by_name("ACADEMY 20")
    expected = { 2011 => {math: 0.816, reading: 0.897, writing: 0.826},
                 2012 => {math: 0.818, reading: 0.893, writing: 0.808},
                 2013 => {math: 0.805, reading: 0.901, writing: 0.810},
                 2014 => {math: 0.800, reading: 0.855, writing: 0.789},
               }
    result = testing.proficient_by_race_or_ethnicity(:asian)
    expected.each do |year, data|
      data.each do |subject, proficiency|
        #require "pry"; binding.pry
        assert_in_delta proficiency, result[year][subject], 0.005
      end
    end
  end

  def test_raises_unknown_race_error
    testing = @str.find_by_name("ACADEMY 20")

        assert_raises(UnknownRaceError) do
          testing.proficient_by_race_or_ethnicity(:pizza).class
      end
  end

  def test_proficient_by_grade_in_year
    testing = @str.find_by_name("ACADEMY 20")
    assert_equal 0.857, testing.proficient_for_subject_by_grade_in_year(:math, 3, 2008)
    assert_raises(UnknownDataError) do
      testing.proficient_for_subject_by_grade_in_year(:math, 4, 2008)
    end
    assert_raises(UnknownDataError) do
      testing.proficient_for_subject_by_grade_in_year(:unicorns, 3, 2008)
    end
    assert_raises(UnknownDataError) do
      testing.proficient_for_subject_by_grade_in_year(:math, 3, 3001)
    end
  end

  def test_proficient_by_race_in_year
    testing = @str.find_by_name("ACADEMY 20")
    assert_equal 0.855, testing.proficient_for_subject_by_race_in_year(:reading, :asian, 2014)
    assert_raises(UnknownDataError) do
      testing.proficient_for_subject_by_race_in_year(:math, :people, 2008)
    end
    assert_raises(UnknownDataError) do
      testing.proficient_for_subject_by_grade_in_year(:unicorns, :white, 2008)
    end
    assert_raises(UnknownDataError) do
      testing.proficient_for_subject_by_grade_in_year(:math, :hispanic, 3001)
    end
  end
end
