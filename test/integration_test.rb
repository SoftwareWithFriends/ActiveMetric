require_relative 'test_helper'

module ActiveMetric

  class IntegrationTest < ActiveSupport::TestCase

    test "can calculate correct eightieth percentile for subject" do
      report = Report.create
      subject = TestSubject.create :report => report
      subject2 = TestSubject.create :report => report
      10.times do |value|
        subject.calculate TestMeasurement.new(:value => 100 - value, :timestamp => value)
      end
      10.times do |value|
        subject2.calculate TestMeasurement.new(:value => 200 - value, :timestamp => value)
      end
      subject2.complete
      subject.complete
      assert_equal 99, subject.summary.eightieth_value.value
      assert_equal 199, subject2.summary.eightieth_value.value
    end

    test "can calculate correct ninety eighth percentile for subject" do
      report = Report.create
      subject = TestSubject.create :report => report
      subject2 = TestSubject.create :report => report
      5.times do |value|
        subject.calculate TestMeasurement.new(:value => 100 - value, :timestamp => value)
      end
      5.times do |value|
        subject.calculate TestMeasurement.new(:value => 150 - value, :timestamp => value)
      end
      10.times do |value|
        subject2.calculate TestMeasurement.new(:value => 200 - value, :timestamp => value)
      end
      subject2.complete
      subject.complete
      assert_equal 150, subject.summary.ninety_eighth_value.value
      assert_equal 200, subject2.summary.ninety_eighth_value.value
    end

    test "can calculate correct percentiles with multiple subjects" do
      report = Report.create
      subject = TestSubject.create :report => report
      subject2 = TestSubject.create :report => report
      5.times do |value|
        subject.calculate TestMeasurement.new(:value => 100 - value, :timestamp => value)
      end
      5.times do |value|
        subject.calculate TestMeasurement.new(:value => 150 - value, :timestamp => value)
      end
      10.times do |value|
        subject2.calculate TestMeasurement.new(:value => 155 - value, :timestamp => value)
      end
      subject2.complete
      subject.complete

      assert_equal 149, subject.summary.eightieth_value.value
      assert_equal 150, subject.summary.ninety_eighth_value.value

      assert_equal 154, subject2.summary.eightieth_value.value
      assert_equal 155, subject2.summary.ninety_eighth_value.value
    end

    test "can calculate standard deviations" do
      report = Report.create
      subject = TestSubject.create :report => report
      10.times do |value|
        subject.calculate TestMeasurement.new(:value => 100 - value, :timestamp => value)
      end

      subject.complete
      assert_close_to 2.87, subject.summary.standard_deviation_value.value
    end

    test "interval samples should order before skip" do
      report = Report.create
      subject = TestSubject.create :report => report
      50.times do |value|
        subject.calculate TestMeasurement.new(:value => value, :timestamp => value)
      end
      subject.complete
      assert_equal 47, subject.interval_samples.skip(9).first.timestamp
    end

    test "summary should update when samples changes" do
      report = Report.create
      subject = TestSubject.create :report => report
      6.times do |value|
        subject.calculate TestMeasurement.new(:value => value, :timestamp => value)
      end

      assert_equal 4.0, subject.summary.eightieth_value.value

      subject.calculate TestMeasurement.new(:value => 6, :timestamp => 6)

      assert_equal 4.0, subject.summary.eightieth_value.value

    end

    test "subjects should delegate to summaries" do
      report = Report.create
      subject = TestSubject.create :report => report
      6.times do |value|
        subject.calculate TestMeasurement.new(:value => value, :timestamp => value)
      end

      assert_equal 4.0, subject.eightieth_value
      assert_equal 4.0, subject.eightieth_value
    end

    test "subjects should delegate to document before summaries" do
      report = Report.create
      subject = TestSubject.create :report => report, :test_field => "subject name"
      6.times do |value|
        subject.calculate TestMeasurement.new(:value => value, :timestamp => value)
      end
      assert_equal "subject name", subject.test_field
      assert_equal 4.0, subject.eightieth_value
    end

    test "subjects should be able to delegate to non stat properties on summary" do
      report = Report.create
      subject = TestSubject.create :report => report
      6.times do |value|
        subject.calculate TestMeasurement.new(:value => value, :timestamp => value)
      end
      assert_equal 5, subject.duration_in_seconds
      assert_equal 5, subject.duration_in_seconds
    end

    private

    def assert_within_threshold(threshold, actual, estimated)
      range_val = actual * threshold
      range = ((actual - range_val)..(actual + range_val))
      assert_within_range range, estimated
    end
  end
end
