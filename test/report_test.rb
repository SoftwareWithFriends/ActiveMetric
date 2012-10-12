require_relative 'test_helper'

module ActiveMetric

  class ReportTest < ActiveSupport::TestCase


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

    test "can delete a report" do
      report = Report.create
      report.subjects.create

      report.delete

      assert_equal 0, ActiveMetric::Report.count
      assert_equal 0, ActiveMetric::Subject.count
      assert_equal 0, ActiveMetric::Sample.count
      assert_equal 0, ActiveMetric::GraphViewModel.count

    end

    test "can set display name" do
      class TestReport < Report

        def set_display_name
          "Overriden Display Name"
        end
      end

      report = TestReport.create

      assert_equal "Overriden Display Name", report.display_name
    end

    test "can set display name through attribute" do
      class TestReport < Report

        def set_display_name
          "TestReport Display Name"
        end
      end

      report = TestReport.create display_name: "Overriden Display Name"

      assert_equal "Overriden Display Name", report.display_name
    end



  end
end