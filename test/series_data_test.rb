require_relative "test_helper"

module ActiveMetric
  class SeriesDataTest < ActiveSupport::TestCase

    test "can instantiate stat definition" do
      access_name = "name_of_stat"
      options = {axis: 2}
      stat_definition = StatDefinition.new(:property,Min,access_name,options)
      series = SeriesData.from_stat_definition(stat_definition)

      assert_equal access_name, series.label
      assert_equal 2, series.y_axis
      assert_equal 0, series.x_axis
    end

    test "can pop" do
      gvm = GraphViewModel.create
      psd = PointSeriesData.new(data: [[1,1],[2,2]])
      gvm.series_data << psd

      psd.pop_data

      assert_equal [[1,1]], psd.data

      psd.push_data([3,3])

      assert_equal [[1,1],[3,3]], psd.data
    end

  end
end