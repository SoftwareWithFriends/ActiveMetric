require 'test_helper'

module ActiveMetric

  class MeasurementAndSubjectTest < ActiveSupport::TestCase

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
        TestMeasurement.create(:subjects => [subject], :value => value)
      end 
      2.times do |value|
        TestMeasurement.create(:subjects => [subject2], :value => value)
      end 
      assert_equal 2, TestMeasurement.by_subject(subject).count
    end

    test "can calculate correct eightieth percentile for subject" do
      subject = Subject.create
      10.times do |value|
        TestMeasurement.create(:subjects => [subject], :value => value)
      end 
      assert_equal 8, TestMeasurement.eightieth(subject, :value).first.value
    end

    test "can calculate correct ninety eighth percentile for subject" do
      subject = Subject.create
      10.times do |value|
        TestMeasurement.create(:subjects => [subject], :value => value)
      end 
      assert_equal 9, TestMeasurement.ninety_eighth(subject, :value).first.value

    end

  end
end
