require_relative "test_helper"

module ActiveMetric
  class SubjectTest < ActiveSupport::TestCase

    test "can lookup subject from db" do
      subject = TestSubject.create name: "Test Subject"
      TestSample.create samplable: subject

      subject_hash = TestSubject.from_db(subject.id.to_s)
      assert_equal subject.id.to_s, subject_hash["_id"].to_s
      assert_equal "ActiveMetric::TestSubject", subject_hash["_type"]
      assert_equal "Test Subject", subject_hash["name"]

      assert_equal "ActiveMetric::TestSample", subject_hash["summary"]["_type"]
      assert_equal 11, subject_hash["summary"]["stats"].count
    end

    test "can lookup subjects from report" do
      report = Report.create
      subject_one = TestSubject.create report: report, name: "Test One"
      TestSample.create samplable: subject_one

      TestSubject.create report: report, name: "Test Two"

      subjects = TestSubject.from_report(report.id.to_s)
      assert_equal 2, subjects.size
      assert_equal "Test One", subjects.first["name"]
      assert_equal "ActiveMetric::TestSample", subjects.first["summary"]["_type"]
      assert_equal "Test Two", subjects.second["name"]

    end

  end
end