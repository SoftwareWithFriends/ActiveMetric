require_relative "test_helper"

module ActiveMetric
  class PointSeriesDataTest < ActiveSupport::TestCase

    test "can push and pop atomically" do
      gvm = GraphViewModel.create
      psd = PointSeriesData.new(data: [[1,1],[2,2]])
      gvm.series_data << psd

      psd.pop_data

      assert_equal [[1,1]], psd.data

      psd.push_data([3,3])

      assert_equal [[1,1],[3,3]], psd.data
    end

    test "can calculate size of data" do
      psd = PointSeriesData.new(data: [[1,1],[2,2]])

      assert_equal 2, psd.size
    end

  end
end