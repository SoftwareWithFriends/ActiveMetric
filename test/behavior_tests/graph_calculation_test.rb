require_relative "../test_helper"

module ActiveMetric
  class GraphCalculationTest < ActiveSupport::TestCase

    test "can update series data" do
      report = Report.create
      subject = TestSubject.create :report => report

      10.times do |value|
        #value += 10
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

    test "graph view model gets created from stats defined" do
      report = Report.create
      subject = TestSubject.create :report => report
      first_stat_name = TestSubject.sample_type.stats_defined.map{|sd| sd.access_name.to_s }.sort.first

      gvm = subject.graph_view_model

      assert_equal first_stat_name, gvm.series_data.map(&:label).sort.first
    end

    test "update series data recalculates last sample if on same index" do
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

    test "retrieving existing subject allows series data to be updated where it left off" do
      report = Report.create
      subject = TestSubject.create :report => report

      14.times do |value|
        subject.calculate TestMeasurement.new(:value => value, :timestamp => value)
      end

      subject.complete

      gvm = subject.graph_view_model

      assert_equal [[2,4],[7,9],[11,13]], gvm.series_for("max_value").data

      same_subject = TestSubject.where(:report => report).first

      same_subject.calculate TestMeasurement.new(:value => 14, :timestamp => 14)
      same_subject.complete

      same_gvm = same_subject.graph_view_model

      same_subject.update_series_data
      assert_equal [[2,4],[7,9],[11,13],[14,14]], same_gvm.series_for("max_value").data
    end

    test "graph view model gets created with approximation as defined in stat then sample class" do
      default_min_approximation = "low"
      default_mean_approximation = "average"
      default_approximation = "high"
      test_sample_defined_approximation = "open"
      report = Report.create
      subject = TestSubject.create :report => report

      gvm = subject.graph_view_model

      assert_equal default_min_approximation, gvm.series_for("min_value").approximation
      assert_equal default_mean_approximation, gvm.series_for("mean_value").approximation
      assert_equal default_approximation, gvm.series_for("max_value").approximation
      assert_equal test_sample_defined_approximation, gvm.series_for("standard_deviation_value").approximation
    end

  end
end