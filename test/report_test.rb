require 'test_helper'

module ActiveMetric

  class ReportTest < ActiveSupport::TestCase

    test "properly busts caches" do
      report = Report.create
      subject = TestSubject.create :report => report
      10.times do |value|
        subject.calculate TestMeasurement.new(:value => 100 - value, :timestamp => value)
      end
      subject.complete
      assert_nil subject.series_data

      subject.update_series_data

      assert_equal 2, subject.series_data.values.first["data"].count

      report.bust_caches
      subject.reload

      assert_nil subject.series_data

      subject.update_series_data
      assert_equal 2, subject.series_data.values.first["data"].count
    end

  end
end