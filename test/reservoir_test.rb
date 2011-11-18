require "test_helper"

module ActiveMetric
  class ReservoirTest < ActiveSupport::TestCase

    class Measurement
      attr_accessor :value
    end

    setup do
      @reservoir = Reservoir.new(:value, 10)
    end

    test "can initialize reservoir with type and size" do
      assert_equal @reservoir.metric, :value
      assert_equal @reservoir.size,   10
    end

    test "can fill reservoir" do
      @reservoir.fill create_measurement(1)
    end

    test "can fill reservoir and calculate percentile" do
      (1..10).reverse_each do |value|
        @reservoir.fill create_measurement(value)
      end
      assert_equal 9, @reservoir.calculate_percentile(0.8)
      assert_equal 10, @reservoir.calculate_percentile(0.98)
    end

    test "can fill reservoir past the size" do
      100.times do |value|
        @reservoir.stubs(:should_replace_at_current_index?).returns(value % 2 > 0)
        @reservoir.fill create_measurement(value % 20)
      end

      assert_equal 2,  @reservoir.calculate_percentile(0.1)
      assert_equal 4,  @reservoir.calculate_percentile(0.2)
      assert_equal 6,  @reservoir.calculate_percentile(0.3)
      assert_equal 8,  @reservoir.calculate_percentile(0.4)
      assert_equal 11, @reservoir.calculate_percentile(0.5)
      assert_equal 13, @reservoir.calculate_percentile(0.6)
      assert_equal 15, @reservoir.calculate_percentile(0.7)
      assert_equal 17, @reservoir.calculate_percentile(0.8)
      assert_equal 19, @reservoir.calculate_percentile(0.9)
    end

    #test "can fill reservoir past the size" do
    #  big_reservoir = Reservoir.new :value, 10000
    #
    #  measurements = []
    #  100000.times do |value|
    #    measurements <<  create_measurement(value % 1000)
    #  end
    #
    #  shuffle(measurements)
    #  measurements.each do |m|
    #    big_reservoir.fill m
    #  end
    #
    #  assert_within_range  (90..110), big_reservoir.calculate_percentile(0.1)
    #  assert_within_range (190..210), big_reservoir.calculate_percentile(0.2)
    #  assert_within_range (290..310), big_reservoir.calculate_percentile(0.3)
    #  assert_within_range (390..410), big_reservoir.calculate_percentile(0.4)
    #  assert_within_range (490..510), big_reservoir.calculate_percentile(0.5)
    #  assert_within_range (590..610), big_reservoir.calculate_percentile(0.6)
    #  assert_within_range (690..710), big_reservoir.calculate_percentile(0.7)
    #  assert_within_range (790..810), big_reservoir.calculate_percentile(0.8)
    #  assert_within_range (890..910), big_reservoir.calculate_percentile(0.9)
    #
    #  assert_within_range (970..990), big_reservoir.calculate_percentile(0.98)
    #end


    private

    def shuffle(array)
      array.size.downto(1) { |n| array.push array.delete_at(rand(n)) }
    end

    def assert_within_range(range, value)
      assert range === value, "Expected #{value} to be within #{range}"
    end

    def create_measurement(value)
      measurement = Measurement.new
      measurement.value = value
      measurement
    end

  end
end