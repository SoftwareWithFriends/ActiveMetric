require_relative "test_helper"

module ActiveMetric
  class ReservoirTest < ActiveSupport::TestCase

    class Measurement
      attr_accessor :value
    end

    setup do
      @reservoir = Reservoir.new(10)
    end

    test "can initialize reservoir with type and size" do
      assert_equal @reservoir.size,   10
    end

    test "can fill reservoir" do
      @reservoir.fill create_measurement(1)
    end

    test "can fill reservoir and calculate percentile" do
      (1..10).reverse_each do |value|
        @reservoir.fill create_measurement(value)
      end
      assert_equal 9, @reservoir.calculate_percentile(0.8, :value)
      assert_equal 10, @reservoir.calculate_percentile(0.98, :value)
    end

    test "calculates based on moving window" do
      (1..20).reverse_each do |value|
        @reservoir.fill create_measurement(value)
      end

      assert_equal 9, @reservoir.calculate_percentile(0.8, :value)
      assert_equal 10, @reservoir.calculate_percentile(0.98, :value)
    end
    
    test "can calculate standard deviation for window" do
      reverse_fill(1..20)
      assert_close_to 2.87, @reservoir.calculate_standard_deviation(:value)
      reverse_fill(95..100)
      assert_close_to 46.56, @reservoir.calculate_standard_deviation(:value)
      reverse_fill(90..95)
      assert_close_to 2.47, @reservoir.calculate_standard_deviation(:value)
    end

    private
    
    def reverse_fill(range)
      range.reverse_each do |value|
        @reservoir.fill create_measurement(value)
      end
    end

    def shuffle(array)
      array.size.downto(1) { |n| array.push array.delete_at(rand(n)) }
    end

    def create_measurement(value)
      measurement = Measurement.new
      measurement.value = value
      measurement
    end

  end
end
