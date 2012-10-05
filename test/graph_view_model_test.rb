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

    test "can create from definitions" do
      axises_defintions = [{index: 1, label: "second"},
                           {index: 0, label: "first"},
                           {index: 0, label: "actually first"}]
      options = {name: "test graph"}

      stat_definitions  = []
      stat_definitions << stat_definition(true)
      stat_definitions << stat_definition(true)
      stat_definitions << stat_definition(false)

      gvm = GraphViewModel.create_from_meta_data(axises_defintions, stat_definitions, options)

      assert_equal 2, gvm.y_axises.size

      index_zero_axises = gvm.y_axises.select{|axis| axis.index == 0}

      assert_equal 1, index_zero_axises.size
      assert_equal 0, index_zero_axises.first.index
      assert_equal "actually first", index_zero_axises.first.label

      assert_equal 2, gvm.series_data.size
    end

    test "can read y_axises sorted by index" do
      axises_defintions = [{index: 1, label: "second"},
                           {index: 0, label: "first"},
                           {index: 0, label: "actually first"}]

      gvm = GraphViewModel.create_from_meta_data(axises_defintions, [], {})

      axises = gvm.ordered_y_axises

      assert_equal 2, axises.size

      assert_equal 0, axises.first.index
      assert_equal "actually first", axises.first.label

      assert_equal 1, axises.second.index
      assert_equal "second", axises.second.label
    end


    test "can retrieve partial array" do
      subject = Subject.create
      graph_view_model = subject.graph_view_model
      graph_view_model.series_data << generate_series_data(4)
      graph_view_model.series_data << generate_series_data(4,"label 2")

      partial_graph = subject.graph_view_model_starting_at(2)
      p partial_graph.series_data.first
      assert_equal [[2,2],[3,3]], partial_graph.series_data.first.data
      assert_equal [[2,2],[3,3]], partial_graph.series_data.second.data

    end

    def generate_series_data(x_count, label = "label")
      data = []
      x_count.times {|x| data << [x,x]}
      PointSeriesData.new(data: data, label: label)
    end

    def stat_definition(graphable)
      axis = graphable ? 0 : -1
      StatDefinition.new(:name_of_stat,Min,"min_name_of_stat",{axis: axis})
    end

  end
end