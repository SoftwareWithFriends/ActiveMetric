require_relative "test_helper"

module ActiveMetric
  class AxisTest < ActiveSupport::TestCase

    test "can create axis" do
      gvm = GraphViewModel.create

      axis_options = {:index => 1, :label => "second"}

      gvm.y_axises << Axis.new(axis_options)


      gvm.save!
      gvm.reload
      assert_equal 1, gvm.y_axises.size
      axis = gvm.y_axises.first
      assert axis

    end
  end
end