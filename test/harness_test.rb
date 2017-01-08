require "minitest"
require "minitest/autorun"
require_relative "../../headcount/lib/district_repository"
require_relative "../../headcount/lib/district"
require_relative "../../headcount/lib/enrollment"
require_relative "../../headcount/lib/enrollment_repository"
require_relative "../../headcount/lib/headcount_analyst"

class IterationZeroTest < Minitest::Test
  def test_district_basics
    d = District.new({:name => "ACADEMY 20"})
    assert_equal "ACADEMY 20", d.name
  end

  def test_loading_and_finding_districts
    dr = DistrictRepository.new
    dr.load_data({
                   :enrollment => {
                     :kindergarten => "./data/Kindergartners in full-day program.csv"
                   }
                 })
    district = dr.find_by_name("ACADEMY 20")

    assert_equal "ACADEMY 20", district.name

    assert_equal 7, dr.find_all_matching("WE").count
  end

  def test_enrollment_basics
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
    all_years = {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}
    assert_in_delta 0.391, e.kindergarten_participation_in_year(2010), 0.005
    assert_in_delta 0.267, e.kindergarten_participation_in_year(2012), 0.005

    truncated = all_years.map { |year, rate| [year, rate.to_s[0..4].to_f]}.to_h
    truncated.each do |k,v|
      assert_in_delta v, e.kindergarten_participation_by_year[k], 0.005
    end
  end

  def test_loading_and_finding_enrollments
    er = EnrollmentRepository.new
    er.load_data({
                   :enrollment => {
                     :kindergarten => "./data/Kindergartners in full-day program.csv"
                   }
                 })

    name = "GUNNISON WATERSHED RE1J"
    enrollment = er.find_by_name(name)
    assert_equal name, enrollment.name
    assert enrollment.is_a?(Enrollment)
    assert_in_delta 0.144, enrollment.kindergarten_participation_in_year(2004), 0.005

  end
end

class IterationOneTest < Minitest::Test
  def test_district_enrollment_relationship_basics
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    district = dr.find_by_name("GUNNISON WATERSHED RE1J")

    assert_in_delta 0.144, district.enrollment.kindergarten_participation_in_year(2004), 0.005
  end

  def test_enrollment_analysis_basics
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv"}})
    ha = HeadcountAnalyst.new(dr)
    assert_in_delta 1.126, ha.kindergarten_participation_rate_variation("GUNNISON WATERSHED RE1J", :against => "TELLURIDE R-1"), 0.005
    assert_in_delta 0.447, ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1'), 0.005
  end
end

class IterationTwoTest < Minitest::Test
  def test_enrollment_repository_with_high_school_data
    er = EnrollmentRepository.new
    er.load_data({
                   :enrollment => {
                     :kindergarten => "./data/Kindergartners in full-day program.csv",
                     :high_school_graduation => "./data/High school graduation rates.csv"
                   }
                 })
    e = er.find_by_name("MONTROSE COUNTY RE-1J")


    expected = {2010=>0.738, 2011=>0.751, 2012=>0.777, 2013=>0.713, 2014=>0.757}
    expected.each do |k,v|
      assert_in_delta v, e.graduation_rate_by_year[k], 0.005
    end
    assert_in_delta 0.738, e.graduation_rate_in_year(2010), 0.005
  end

  def test_high_school_versus_kindergarten_analysis
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv",
                                  :high_school_graduation => "./data/High school graduation rates.csv"}})
    ha = HeadcountAnalyst.new(dr)

    assert_in_delta 0.548, ha.kindergarten_participation_against_high_school_graduation('MONTROSE COUNTY RE-1J'), 0.005
    assert_in_delta 0.800, ha.kindergarten_participation_against_high_school_graduation('STEAMBOAT SPRINGS RE-2'), 0.005
  end

  def test_does_kindergarten_participation_predict_hs_graduation
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv",
                                  :high_school_graduation => "./data/High school graduation rates.csv"}})
    ha = HeadcountAnalyst.new(dr)

    assert ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'ACADEMY 20')
    refute ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'MONTROSE COUNTY RE-1J')
    refute ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'SIERRA GRANDE R-30')
    assert ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'PARK (ESTES PARK) R-3')
  end

  def test_statewide_kindergarten_high_school_prediction
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv",
                                  :high_school_graduation => "./data/High school graduation rates.csv"}})
    ha = HeadcountAnalyst.new(dr)

    refute ha.kindergarten_participation_correlates_with_high_school_graduation(:for => 'STATEWIDE')
  end

  def test_kindergarten_hs_prediction_multi_district
    dr = DistrictRepository.new
    dr.load_data({:enrollment => {:kindergarten => "./data/Kindergartners in full-day program.csv",
                                  :high_school_graduation => "./data/High school graduation rates.csv"}})
    ha = HeadcountAnalyst.new(dr)
    districts = ["ACADEMY 20", 'PARK (ESTES PARK) R-3', 'YUMA SCHOOL DISTRICT 1']
    assert ha.kindergarten_participation_correlates_with_high_school_graduation(:across => districts)
  end
end
