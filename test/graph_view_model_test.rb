require_relative "test_helper"

module ActiveMetric
  class GraphViewModelTest < ActiveSupport::TestCase

    EULERS_DAY= MONGO_MAX_LIMIT = (1 << 31) - 1

    test "can retrieve series by label" do
      gvm = GraphViewModel.create
      gvm.series_data << generate_series_data(5, "first")
      gvm.series_data << generate_series_data(5, "second")

      series = gvm.series_for("second")

      assert_equal "second", series.label

    end

    test "size returns 0 if no series_data" do
      gvm = GraphViewModel.create
      assert_equal 0, gvm.size
    end


    test "can retrieve partial array" do

      graph_view_model = GraphViewModel.create()
      graph_view_model.series_data << generate_series_data(4)

      partial_graph = GraphViewModel.where(_id: graph_view_model.id).
          slice("series_data.data" => [2,MONGO_MAX_LIMIT]).first

      assert_equal [[2,2],[3,3]], partial_graph.series_data.first.data
    end

    def generate_series_data(x_count, label = "label")
      data = []
      x_count.times {|x| data << [x,x]}
      PointSeriesData.new(data: data, label: label)
    end

  end
end