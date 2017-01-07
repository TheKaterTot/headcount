require_relative "../../headcount/lib/enrollment"



class CleanupTest < Minitest::Test
  def test_truncates_float
    e = Enrollment.new({:name => "Academy 20", :kindergarten_participation => {"2010" => "0.1345"}} )

    assert_in_delta 0.134, e.truncates_float("0.1345"), 0.005
  end



  def test_sanitize
    e = Enrollment.new({:name => "Academy 20", :kindergarten_participation => {"2010" => "0.1345"}} )

    assert_equal({2010 => 0.134}, e.sanitize({"2010" => "0.1345"}))
  end

end
