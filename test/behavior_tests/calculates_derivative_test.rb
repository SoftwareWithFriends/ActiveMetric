require_relative "../test_helper"

module ActiveMetric
  class CalculatesDerivativeTest < ActiveSupport::TestCase

    class CalculatesDerivativeStat
      include CalculatesDerivative
    end

    attr_reader :stat

    setup do
      @stat = CalculatesDerivativeStat.new
    end

    test 'can calculate derivative' do
      assert_equal 0.05, stat.calculate_derivative(5, 10, 100)
    end

    test 'returns 0 for no duration' do
      assert_equal 0, stat.calculate_derivative(5, 10, 0)

    end

    test 'can calculate derivative from seed measurement' do
      calculable = mock
      calculable.expects(:duration_from_previous_sample_in_seconds).returns(100)
      stat.expects(:calculable).returns(calculable)
      assert_equal 0.05, stat.derivative_from_seed_measurement(5, 10)
    end


  end

end
