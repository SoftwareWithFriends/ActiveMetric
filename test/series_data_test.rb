require_relative "test_helper"

module ActiveMetric
  class SeriesDataTest < ActiveSupport::TestCase

    test "can instantiate from meta data" do
      label = "name_of_stat"
      meta_data = {:name => label, :axis => 2}
      series = SeriesData.from_meta_data(meta_data)

      assert_equal label, series.label
      assert_equal 2, series.y_axis
      assert_equal 0, series.x_axis
    end

    test "can pop" do
      gvm = GraphViewModel.create
      psd = PointSeriesData.new(data: [[1,1],[2,2]])
      gvm.series_data << psd

      psd.pop

      assert_equal [[1,1]], psd.data

      psd.push([3,3])

      assert_equal [[1,1],[3,3]], psd.data

      p psd.data
    end

  end
end