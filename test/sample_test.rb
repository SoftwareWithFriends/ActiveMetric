require_relative "test_helper"

module ActiveMetric
  class SampleTest < ActiveSupport::TestCase

    test "should have the correct stats by name" do
      subject = TestSubject.new
      sample = TestSample.new(:samplable => subject)
      assert_equal 11, sample.stats.size
      assert_kind_of Min, sample.min_value
      assert_kind_of Mean, sample.mean_value
      assert_kind_of Max, sample.max_value
      assert_kind_of Eightieth, sample.eightieth_value
      assert_kind_of NinetyEighth, sample.ninety_eighth_value
      assert_kind_of StandardDeviation, sample.standard_deviation_value
      assert_kind_of Delta, sample.delta_value
      assert_kind_of Bucket, sample.bucket_value
      assert_kind_of Speed, sample.speed_value
      assert_kind_of TestCount, sample.test_count
      assert_kind_of TestResponseCodes, sample.test_response_codes
    end

    test "can lookup summary from db directly" do
      subject = TestSubject.create
      sample = TestSample.create(:samplable => subject)

      sample_hash = TestSample.from_samplable(subject.id.to_s)
      assert_equal sample.id.to_s, sample_hash["_id"].to_s
      assert_equal 11, sample_hash["stats"].size
    end

    test "samples spawned from samples contain seed measurement" do
      subject = TestSubject.new

      num_measurements = 5

      sample = TestSample.new(:interval => 6, :samplable => subject)

      num_measurements.times do |time|
        sample.calculate TestMeasurement.new :value => 1, :timestamp => time
      end

      new_sample = sample.new_sample

      assert_not_equal sample, new_sample
      assert_equal 4, new_sample.seed_measurement.timestamp
      assert_equal sample.latest_measurement, new_sample.seed_measurement
    end

    test "should have correct timestamp" do
      measurements = [TestMeasurement.new(:value => 10, :timestamp => 1),
                      TestMeasurement.new(:value => 12, :timestamp => 2),
                      TestMeasurement.new(:value => 11, :timestamp => 9)]

      subject = TestSubject.create
      sample = TestSample.new(:samplable => subject)
      measurements.each do |measurement|
        sample.calculate(measurement)
      end
      assert_equal (4), sample.timestamp
    end

    test "should call calculate on all stats" do
      subject = TestSubject.create
      sample = TestSample.new(:samplable => subject)
      5.times do |value|
        measurement = TestMeasurement.new :value => value, :timestamp => 1
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

    test "summary only should set start time after first measurement" do
      subject = TestSubject.create
      summary = subject.summary
      assert_nil summary.start_time


      summary.calculate(TestMeasurement.new :value => 1, :timestamp => 1)
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

    test "stat definitions have proper axis" do
      @stat_definitions = TestSample.stats_defined
      assert_contains_axis(:min_value,0)
      assert_contains_axis(:mean_value,0)
      assert_contains_axis(:max_value,0)
      assert_contains_axis(:standard_deviation_value,1)
      assert_contains_axis(:test_count,1)
      assert_contains_axis(:test_response_codes, -1)
    end

    def assert_contains_axis(stat,axis)
      assert_equal axis, @stat_definitions.select {|sd| sd.access_name == stat}.first.options[:axis]
    end

  end
end