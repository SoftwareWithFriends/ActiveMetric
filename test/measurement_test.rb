require 'test_helper'

module ActiveMetric

  class MeasurementTest < ActiveSupport::TestCase

    setup do
      @measurement = TestMeasurement.new
    end

    test 'can create measurement' do
      assert @measurement
    end

    test 'is a mongoid document' do
      assert @measurement.kind_of? Mongoid::Document
    end

    test 'time returns datetime in seconds for timestamp' do
      @measurement.timestamp = 1318338826385
      assert_equal Time.at(1318338826), @measurement.time
    end

    test "converts appropriate fields to integer" do
      assert_saves_as_integer @measurement, :timestamp
    end

    test "measurements default timestamp to now" do
      assert @measurement.timestamp
      measurement2 = TestMeasurement.new
      assert measurement2.timestamp

      assert_not_equal @measurement.timestamp, measurement2.timestamp
    end

    private

    def assert_saves_as_integer(measurement, field)
      measurement.send("#{field}=","12345")
      measurement.save!
      assert_equal 12345, measurement.send(field)
    end
  end
end
