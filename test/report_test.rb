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

    test "method missing for subjects" do
      report = Report.create
      subjects = 2.times.map  {TestSubject.create :report => report}
      assert_equal subjects, report.test_subjects
    end

    test "responds properly to method missing if not a subject name" do
      report = Report.create
      assert_raises NoMethodError do
        report.bad_method
      end
    end

    test "can still use dynamic fields with overwritten method missing" do
      report = Report.create :some_random_field => "value"
      assert_equal "value", report.some_random_field
    end

    test "can still access dynamic fields with subjects in name" do
      report = Report.create :some_subjects => "value"
      assert_equal "value", report.some_subjects
    end

  end
end