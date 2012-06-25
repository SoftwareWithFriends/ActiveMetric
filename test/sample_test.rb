require_relative "test_helper"

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

    test "samples spawned from samples contain seed measurement" do
      subject = TestSubject.new

      num_measurements = 5

      sample = TestSample.new(:interval => 6, :samplable => subject)

      num_measurements.times do |time|
        sample.calculate TestMeasurement.create :value => 1, :timestamp => time
      end

      sample.expects(:complete)
      new_sample = sample.calculate TestMeasurement.create :value => 1, :timestamp => 10

      assert_not_equal sample, new_sample
      assert_equal 4, new_sample.seed_measurement.timestamp
      assert_equal sample.latest_measurement, new_sample.seed_measurement
    end

    test "should not save if sample has no measurements" do
      subject = TestSubject.new
      sample = TestSample.new(:interval => 6, :samplable => subject)

      assert_equal false, sample.complete
      assert_equal 0, TestSample.count
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

    test "is summary" do
      subject = TestSubject.create
      summary = subject.summary
      assert summary.is_summary?
    end

    test "summary only should save itself with start time after first measurement" do
      subject = TestSubject.create
      summary = subject.summary
      assert_nil summary.start_time


      summary.calculate(TestMeasurement.create :value => 1, :timestamp => 1)
      assert_equal 1, summary.start_time

      summary.reload
      assert_equal 1, summary.start_time
    end

    test "duration from previous sample defaults to current sample duration if no previous sample" do
      nil_seed_measurement = nil
      sample = TestSample.new({},nil_seed_measurement)
      sample.expects(:duration_in_seconds)
      sample.duration_from_previous_sample_in_seconds
    end

    test "duration from previous sample returns correct duration" do
      seed_measurement = mock

      seed_measurement.expects(:timestamp).returns(100)

      sample = TestSample.new({},{}, seed_measurement)
      sample.expects(:end_time).returns(200)

      assert_equal 100, sample.duration_from_previous_sample_in_seconds
    end

    test "passing in just a hash to create sets seed measurement to nil" do
      subject = TestSubject.new

      sample = TestSample.create( {:samplable => subject, :foo => "bar"} )
      assert_nil sample.seed_measurement

    end

  end
end