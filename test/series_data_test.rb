require_relative "test_helper"

module ActiveMetric
  class SeriesDataTest < ActiveSupport::TestCase

    test "can instantiate from stat definition" do
      access_name = "name_of_stat"
      options = {axis: 2, visible: false}
      stat_definition = StatDefinition.new(:property,Min,access_name,options)
      series = SeriesData.from_stat_definition(stat_definition)

      assert_equal access_name, series.label
      assert_equal 2, series.y_axis
      assert_equal 0, series.x_axis
      assert_equal false, series.visible
    end


  end
end