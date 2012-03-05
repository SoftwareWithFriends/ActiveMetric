require 'test_helper'

module ActiveMetric

  class ReportTest < ActiveSupport::TestCase

    test "properly busts caches and recalculates them" do
      report = Report.create
      subject = TestSubject.create :report => report
      10.times do |value|
        subject.calculate TestMeasurement.new(:value => 100 - value, :timestamp => value)
      end
      subject.complete

      assert_equal 2, subject.series_data.values.first["data"].count

      10.times do |value|
        subject.calculate TestMeasurement.new(:value => 100 - value, :timestamp => value + 10)
      end
      subject.complete

      report.bust_caches
      subject.reload

      assert_equal 4, subject.series_data.values.first["data"].count
    end

  end
end