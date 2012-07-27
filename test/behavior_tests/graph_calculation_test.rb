require_relative "../test_helper"

module ActiveMetric
  class GraphCalculationTest < ActiveSupport::TestCase

    test "can update series data" do
      report = Report.create
      subject = TestSubject.create :report => report

      10.times do |value|
        subject.calculate TestMeasurement.new(:value => value, :timestamp => value)
      end

      subject.complete


      gvm = subject.graph_view_model

      assert_equal [[2,4],[7,9]], gvm.series_for("max_value").data
      assert_equal [[2,0],[7,5]], gvm.series_for("min_value").data
      assert_equal [[2,2],[7,7]], gvm.series_for("mean_value").data
      assert_equal [[2,4],[7,8]], gvm.series_for("eightieth_value").data
      assert_equal [[2,4],[7,9]], gvm.series_for("ninety_eighth_value").data

      10.times do |value|
        subject.calculate TestMeasurement.new(:value => value + 10, :timestamp => value + 10)
      end

      subject.complete
    end

    test "series return empty cache if no series data" do
      report = Report.create
      subject = TestSubject.create :report => report
      stat_names = TestSubject.sample_type.new.stat_meta_data.values.map{|md| md[:name].to_s}

      gvm = subject.graph_view_model

      assert_equal stat_names.sort, gvm.series_data.map(&:label).sort
    end


    test "update series data recalculates last sample" do
      report = Report.create
      subject = TestSubject.create :report => report

      9.times do |value|
        subject.calculate TestMeasurement.new(:value => value, :timestamp => value)
      end

      subject.complete

      gvm = subject.graph_view_model

      assert_equal [[2,4],[6,8]], gvm.series_for("max_value").data


      subject.calculate TestMeasurement.new(:value => 9, :timestamp => 9)
      subject.complete

      subject.update_series_data
      assert_equal [[2,4],[7,9]], gvm.series_for("max_value").data
    end



  end
end