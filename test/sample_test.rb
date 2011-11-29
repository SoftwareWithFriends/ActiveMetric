require "test_helper"

module ActiveMetric
  class SampleTest < ActiveSupport::TestCase

    test "should have the correct stats by name" do
      subject = TestSubject.new

      sample = TestSample.create(:samplable => subject)
      sample = TestSample.find sample.id
      assert_equal 8, sample.stats.size
      assert_kind_of Min, sample.min_value
      assert_kind_of Mean, sample.mean_value
      assert_kind_of Max, sample.max_value
      assert_kind_of Eightieth, sample.eightieth_value
      assert_kind_of NinetyEighth, sample.ninety_eighth_value
      assert_kind_of StandardDeviation, sample.standard_deviation_value
      assert_kind_of Custom, sample.test_count
      assert_kind_of Custom, sample.test_response_codes
    end

    test "should have sames stats when reloaded" do
      subject = TestSubject.new

      sample = TestSample.create :samplable => subject
      sample.calculate TestMeasurement.create(:value => 10, :timestamp => 1234)
      sample.save!
      assert_equal 10, sample.min_value.value
    end

    test "sample without interval should return self always" do
      subject = TestSubject.new
      sample = TestSample.new :samplable => subject
      sample.calculate TestMeasurement.create(:value => 10, :timestamp => 1234)
      new_sample = sample.calculate TestMeasurement.create(:value => 10, :timestamp => 91234)

      assert_equal sample,new_sample
    end

    test "calculate calls complete and returns new sample if measurement outside of sample size" do
      subject = TestSubject.new

      sample = TestSample.new(:interval => 6, :samplable => subject)
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
      subject = TestSubject.create
      sample = TestSample.create(:samplable => subject)
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

    test "should return raw stat if sample does not have that stat" do
      sample = TestSample.new
      stat = sample.this_stat_does_not_exist
      assert_equal 0, stat.value
    end

    test "should return stat if sample has it" do
      sample = TestSample.new
      stat = sample.min_value
      assert stat.kind_of? Min
    end

  end
end