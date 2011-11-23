require "test_helper"
module ActiveMetric
  class StandardDeviatorTest < ActiveSupport::TestCase

    test "can calculate standard deviation" do
      sd = StandardDeviator.new(:value)
      test_stat(sd, 100.times)
      assert_close_to 28.87, sd.standard_deviation
    end

    private

    def test_stat(stat, values)
      values.each  do |value|
        stat.calculate TestMeasurement.new(:value => value)
      end
    end


  end

end