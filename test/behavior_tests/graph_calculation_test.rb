require "test_helper"

module ActiveMetric
  class GraphCalculationTest < ActiveSupport::TestCase

    test "can calculate series" do
      report = Report.create
      subject = TestSubject.create :report => report

      10.times do |value|
        subject.calculate TestMeasurement.new(:value => value, :timestamp => value)
      end

      subject.complete

      report.subjects.each do |subject|
        subject.series
        assert_equal [[2,4],[7,9]], subject.series_data["max_value"][:data]
        assert_equal [[2,0],[7,5]],  subject.series_data["min_value"][:data]
        assert_equal [[2,2],[7,7]], subject.series_data["mean_value"][:data]
        assert_equal [[2,4],[7,8]],  subject.series_data["eightieth_value"][:data]
        assert_equal [[2,4],[7,9]], subject.series_data["ninety_eighth_value"][:data]
      end
    end

  end
end