require "test_helper"

module ActiveMetric
  class SampleTest < ActiveSupport::TestCase

    test "should have the correct stats by name" do
      sample = TestSample.create
      sample = TestSample.find sample.id
      assert_equal 7, sample.stats.size
      assert_kind_of Min, sample.min_value
      assert_kind_of Mean, sample.mean_value
      assert_kind_of Max, sample.max_value
      assert_kind_of Eightieth, sample.eightieth_value
      assert_kind_of NinetyEighth, sample.ninety_eighth_value
      assert_kind_of Stat, sample.test_count
      assert_kind_of Stat, sample.test_response_codes
    end

    test "should have sames stats when reloaded" do
      sample = TestSample.create
      sample.calculate TestMeasurement.create(:value => 10, :timestamp => 1234)
      sample.save!
      #sample = TestSample.find sample.id
      assert_equal 10, sample.min_value.value
    end

    test "sample without interval should return self always" do
      sample = TestSample.new
      sample.calculate TestMeasurement.create(:value => 10, :timestamp => 1234)
      new_sample = sample.calculate TestMeasurement.create(:value => 10, :timestamp => 91234)

      assert_equal sample,new_sample
    end

    test "calculate calls complete and returns new sample if measurement outside of sample size" do
      sample = TestSample.new(:interval => 6)
      5.times do |time|
        sample.calculate TestMeasurement.create :value => 1, :timestamp => time
      end

      sample.expects(:complete)
      new_sample = sample.calculate TestMeasurement.create :value => 1, :timestamp => 10

      assert_not_equal sample, new_sample
    end

    test "should have correct timestamp" do
      measurements = [TestMeasurement.create(:value => 10, :timestamp => 1),
                      TestMeasurement.create(:value => 12, :timestamp => 2),
                      TestMeasurement.create(:value => 11, :timestamp => 9)]

      subject = TestSubject.create
      sample = TestSample.create(:samplable => subject)
      measurements.each do |measurement|
        sample.calculate(measurement)
      end
      sample.safely.save!
      sample = TestSample.find sample.id
      assert_equal (4), sample.timestamp
    end

    test "should call calculate on all stats" do
      sample = TestSample.new
      5.times do |value|
        measurement = TestMeasurement.create :value => value, :timestamp => 1
        sample.stats.each do |stat|
          stat.expects(:calculate).with(measurement)
        end
        sample.calculate measurement
      end

      sample.stats.each do |stat|
        stat.expects(:complete)
      end
      sample.complete
    end





  end
end