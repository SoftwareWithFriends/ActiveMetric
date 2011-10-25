require 'test_helper'

module ActiveMetric

  class IntegrationTest < ActiveSupport::TestCase

    setup do
      @measurement = TestMeasurement.new
    end

    test "has many subjects" do
      subject1 = Subject.create
      subject2 = Subject.create
      subjects = [subject1, subject2]
      @measurement.subjects.concat subjects
      @measurement.save!

      @measurement.reload
      subjects.each do |subject|
        assert @measurement.subjects.include?(subject)
      end
    end

    test "scopes by subject" do
      subject  = Subject.create
      subject2 = Subject.create
      2.times do |value|
        TestMeasurement.create(:subjects => [subject],  :value => 100 - value, :timestamp => value)
      end 
      2.times do |value|
        TestMeasurement.create(:subjects => [subject2], :value => 200 - value, :timestamp => value)
      end 
      assert_equal 2, TestMeasurement.by_subject(subject).count
    end

    test "can calculate correct eightieth percentile for subject" do
      report = Report.create
      subject = report.subjects.create
      subject2 = report.subjects.create
      10.times do |value|
        subject.calculate TestMeasurement.create(:subjects => [subject],  :value => 100 - value, :timestamp => value)
      end
      10.times do |value|
        subject2.calculate TestMeasurement.create(:subjects => [subject2], :value => 200 - value, :timestamp => value)
      end
      subject2.complete
      subject.complete
      assert_equal 99, subject.summary.eightieth_value.value
      assert_equal 199, subject2.summary.eightieth_value.value
    end

    test "can calculate correct ninety eighth percentile for subject" do
      report = Report.create
      subject = report.subjects.create
      subject2 = report.subjects.create
      5.times do |value|
        subject.calculate TestMeasurement.create(:subjects => [subject],  :value => 100 - value, :timestamp => value)
      end
      5.times do |value|
        subject.calculate TestMeasurement.create(:subjects => [subject],  :value => 150 - value, :timestamp => value)
      end
      10.times do |value|
        subject2.calculate TestMeasurement.create(:subjects => [subject2], :value => 200 - value, :timestamp => value)
      end
      subject2.complete
      subject.complete
      assert_equal 150, subject.summary.ninety_eighth_value.value
      assert_equal 200, subject2.summary.ninety_eighth_value.value
    end

    test "can calculate correct percentiles with multiple subjects" do
      report = Report.create
      subject = report.subjects.create
      subject2 = report.subjects.create
      5.times do |value|
        subject.calculate TestMeasurement.create(:subjects => [subject],  :value => 100 - value, :timestamp => value)
      end
      5.times do |value|
        subject.calculate TestMeasurement.create(:subjects => [subject, subject2],  :value => 150 - value, :timestamp => value)
      end
      10.times do |value|
        subject2.calculate TestMeasurement.create(:subjects => [subject2], :value => 155 - value, :timestamp => value)
      end
      subject2.complete
      subject.complete

      assert_equal 149, subject.summary.eightieth_value.value
      assert_equal 150, subject.summary.ninety_eighth_value.value

      assert_equal 153, subject2.summary.eightieth_value.value
      assert_equal 155, subject2.summary.ninety_eighth_value.value
    end
  end
end