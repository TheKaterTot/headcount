require_relative "../../headcount/lib/enrollment"
require_relative "test_helper"



class CleanupTest < Minitest::Test
  def test_truncates_float
    e = Enrollment.new({:name => "Academy 20", :kindergarten_participation => {"2010" => "0.1345"}})

    assert_in_delta 0.134, e.truncates_float("0.1345"), 0.005
  end



  def test_sanitize
    e = Enrollment.new({:name => "Academy 20", :kindergarten_participation => {"2010" => "0.1345"}})

    assert_equal({2010 => 0.135}, e.sanitize({"2010" => "0.1345"}))
  end

  def test_sanitize_hash_with_arrays
    e = Enrollment.new({:name => "academy 20", :kindergarten_participation => {["2010", "2009"] => "1.1345"}})

    assert_equal({[2010, 2009] => 1}, e.sanitize_hash_with_array(({["2010", "2009"] => "1.1345"})))
  end

end
