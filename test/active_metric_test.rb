require 'test_helper'

class ActiveMetricTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, ActiveMetric
  end

  test "Version" do
    assert_equal "0.0.1", ActiveMetric::VERSION
  end
end
