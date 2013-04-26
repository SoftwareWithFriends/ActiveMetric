require_relative "test_helper"
module ActiveMetric
  class StandardDeviatorTest < ActiveSupport::TestCase

    test "can calculate standard deviation" do
      sd = StandardDeviator.new(:value)
      test_stat(sd, 100.times)
      assert_close_to 28.87, sd.standard_deviation
    end

    test "memoize standard deviation with a single measurement" do
      sd = StandardDeviator.new(:value)
      sd.expects(:calculate_standard_deviation).returns(5)
      test_stat(sd, 1.times)
      assert_equal 5, sd.standard_deviation
      assert_equal 5, sd.standard_deviation
    end

    test "un-memoizes standard deviation with new measurement" do
      sd = StandardDeviator.new(:value)
      sd.expects(:calculate_standard_deviation).twice.returns(5,2)
      test_stat(sd, 1.times)
      assert_equal 5, sd.standard_deviation
      assert_equal 5, sd.standard_deviation
      test_stat(sd, 1.times)
      assert_equal 2, sd.standard_deviation
    end

    test "can calculate standard deviation with no calculations " do
      sd = StandardDeviator.new(:value)
      assert_equal 0, sd.standard_deviation
    end

    private

    def test_stat(stat, values)
      values.each do |value|
        stat.calculate TestMeasurement.new(:value => value)
      end
    end


  end

end
