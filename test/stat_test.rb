require_relative 'test_helper'

module ActiveMetric
  class StatTest < ActiveSupport::TestCase

    setup do
      @subject = TestSubject.create
      @sample = TestSample.create({:samplable => @subject})
      @stat = TestStat.new :property, :calculable => @sample
    end

    test "create a new stat" do
      assert @stat
    end

    test "stat is a mongoid document" do
      assert @stat.kind_of?(Mongoid::Document)
    end

    test "calculate raises an error if not implemented" do
      assert_raise CannotInstantiateBaseStat do
        @stat.calculate(mock)
      end
    end

    test "has a dynamically defined name" do
      assert_equal :test_stat_property, @stat.access_name
    end

    test "sets name for custom stat" do
      proc = Proc.new { |m| self.value = m.value }
      stat = Stat.create_custom_stat(:property, Integer, {}, proc).new(:property)
      assert_equal :property, stat.access_name
    end

    test "custom stat uses block to calculate" do
      proc = Proc.new { |m| self.value = m.value }
      stat = Stat.create_custom_stat(:property, Integer, {}, proc).new(:property)
      measurement = mock(:value => 10)
      stat.calculate(measurement)
      assert_equal 10, stat.value
    end

    test "can calculate min" do
      stat = Min.new(:value, :calculable => @sample)
      test_stat(stat, 10.times)
      assert_equal 0, stat.value
    end

    test "can calculate max" do
      stat = Max.new(:value, :calculable => @sample)
      test_stat(stat, 10.times)
      assert_equal 9, stat.value
    end

    test "can calculate mean" do
      stat = Mean.new(:value, :calculable => @sample)
      test_stat(stat, 10.times)
      assert_equal 4.5, stat.value
    end

    test "can calculate derivative without seed_measurement" do
      stat = Derivative.new(:value, :calculable => @sample)
      @sample.stubs(:seed_measurement).returns(nil)

      @sample.expects(:duration_from_previous_sample_in_seconds).times(2).returns(0, 1)
      test_stat(stat, [1, 2])
      slope_of_one = 1.0

      assert_equal slope_of_one, stat.value
    end

    test "can calculate derivative with seed_measurement " do
      stat = Derivative.new(:value, :calculable => @sample)

      @sample.stubs(:seed_measurement).returns(test_seed_measurement)
      @sample.expects(:duration_from_previous_sample_in_seconds).times(2).returns(1, 2)
      test_stat(stat, [2, 3])

      slope_of_one = 1.0

      assert_equal slope_of_one, stat.value
    end

    test "can calculate last derivative without seed_measurement" do
      stat = LastDerivative.new(:value, :calculable => @sample)
      @sample.stubs(:seed_measurement).returns(nil)

      test_stat(stat, [1])
      no_derivative = 0

      assert_equal no_derivative, stat.value
    end

    test "can calculate last derivative with seed measurement" do
      stat = LastDerivative.new(:value, :calculable => @sample)

      @sample.stubs(:seed_measurement).returns(test_seed_measurement)
      test_stat(stat, [2, 4], [2, 3])

      slope_of_two = 2.0

      assert_equal slope_of_two, stat.value
    end

    test "can calculate speed" do
      stat = Speed.new(:value, :calculable => @sample)

      @sample.stubs(:seed_measurement).returns(test_seed_measurement)
      @sample.expects(:duration_from_previous_sample_in_seconds).times(4).returns(1, 2, 3, 4)

      test_stat(stat, [2, 3, 4, 5])

      speed_of_one_per_second = 1.0
      assert_equal speed_of_one_per_second, stat.value

    end

    test "can calculate delta without seed measurement" do
      stat = Delta.new(:value, :calculable => @sample)
      @sample.stubs(:seed_measurement).returns(nil)

      test_stat(stat, [1, 5, 10])
      assert_equal 9, stat.value
    end

    test "can calculate delta with seed measurement" do
      stat = Delta.new(:value, :calculable => @sample)
      @sample.stubs(:seed_measurement).returns(test_seed_measurement)

      test_stat(stat, [5, 10])
      assert_equal 9, stat.value
    end

    test "can calculate sum" do
      stat = Sum.new(:value, :calculable => @sample)
      test_stat(stat, 10.times)
      assert_equal 45, stat.value
    end

    test "can calculate last" do
      stat = Last.new(:value, :calculable => @sample)
      test_stat(stat, 10.times)
      assert_equal 9, stat.value
    end

    test "can calculate count" do
      stat = Count.new(:value, :calculable => @sample)
      test_stat(stat, 10.times)
      assert_equal 10, stat.value
    end

    test "can calculate true count" do
      stat = TrueCount.new(:value, :calculabe => @sample)
      values = [true, true, false]
      test_stat(stat, values)
      assert_equal 2, stat.value
    end

    test "can calculate false count" do
      stat = FalseCount.new(:value, :calculabe => @sample)
      values = [true, true, false]
      test_stat(stat, values)
      assert_equal 1, stat.value
    end

    test "can bucket values" do
      stat = Bucket.new(:value, :calculabe => @sample)
      values = [200, 404, 500, 502, 200, 500, 504.2]
      test_stat(stat, values)
      expected_bucket = {
          "200" => 2,
          "404" => 1,
          "500" => 2,
          "502" => 1,
          "504_2" => 1
      }
      assert_equal expected_bucket, stat.value
    end


    #this test is here for the user, not for automated tests
    #test "random distributions are good too" do
    #  stat = StandardDeviation.new(:value, :calculable => @sample)
    #  100.times do
    #    stat.calculate TestMeasurement.create(:value => rand(100))
    #  end
    #  stat.complete
    #  assert_close_to 28.87, stat.value
    #end

    test "has subject" do
      subject = TestSubject.create
      sample = TestSample.create(:samplable => subject)
      assert_equal subject, sample.stats.first.subject
    end

    private

    def test_stat(stat, values, timestamps = values.to_a)
      values.each_with_index do |value, index|
        stat.calculate TestMeasurement.new(:value => value, :timestamp => timestamps[index])
      end
      stat.complete
    end

    def test_seed_measurement
      seed_measurement = mock()
      seed_measurement.stubs(:value).returns(1)
      seed_measurement.stubs(:timestamp).returns(1)
      seed_measurement
    end

  end
end