require "test_helper"

module ActiveMetric
  class GraphCalculationTest < ActiveSupport::TestCase

    test "can update series data" do
      report = Report.create
      subject = TestSubject.create :report => report

      10.times do |value|
        subject.calculate TestMeasurement.new(:value => value, :timestamp => value)
      end

      subject.complete

      report.subjects.each do |subject|
        subject.update_series_data
        assert_equal [[2,4],[7,9]], subject.series_data["max_value"]["data"]
        assert_equal [[2,0],[7,5]],  subject.series_data["min_value"]["data"]
        assert_equal [[2,2],[7,7]], subject.series_data["mean_value"]["data"]
        assert_equal [[2,4],[7,8]],  subject.series_data["eightieth_value"]["data"]
        assert_equal [[2,4],[7,9]], subject.series_data["ninety_eighth_value"]["data"]
      end
    end

    test "appropriately calculates current cache size" do
      report = Report.create
      subject = TestSubject.create :report => report

      10.times do |value|
        subject.calculate TestMeasurement.new(:value => value, :timestamp => value)
      end

      subject.complete
      subject.update_series_data
      assert_equal 2, subject.size_of_cache_data

      15.times do |value|
        subject.calculate TestMeasurement.new(:value => 10 + value, :timestamp => 10 + value)
      end

      subject.complete
      assert_equal 5, subject.size_of_cache_data
    end

    test "series return empty cache if no series data" do
      report = Report.create
      subject = TestSubject.create :report => report

      assert_nil subject.series_data

      assert_equal [
                       {"name"=>"max_value", "data"=>[], "yAxis"=>0},
                       {"name"=>"min_value", "data"=>[], "yAxis"=>0},
                       {"name"=>"mean_value", "data"=>[], "yAxis"=>0},
                       {"name"=>"test_count", "data"=>[], "yAxis"=>1},
                       {"name"=>"eightieth_value", "data"=>[], "yAxis"=>0},
                       {"name"=>"standard_deviation_value", "data"=>[], "yAxis"=>0},
                       {"name"=>"ninety_eighth_value", "data"=>[], "yAxis"=>0}].sort{|a,b| a["name"] <=> b["name"]}, subject.series.sort{|a,b| a["name"] <=> b["name"]}
    end

    test "calling series does not update subject" do
      report = Report.create
      subject = TestSubject.create :report => report

      subject.series

      assert_nil subject.series_data
    end

    test "update series data recalculates last sample" do
      report = Report.create
      subject = TestSubject.create :report => report

      9.times do |value|
        subject.calculate TestMeasurement.new(:value => value, :timestamp => value)
      end

      subject.complete

      subject.update_series_data

      assert_equal [[2,4],[6,8]], subject.series_data["max_value"]["data"]


      subject.calculate TestMeasurement.new(:value => 9, :timestamp => 9)
      subject.complete

      subject.update_series_data
      assert_equal [[2,4],[7,9]], subject.series_data["max_value"]["data"]
    end

  end
end