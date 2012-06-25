require_relative "test_helper"

module ActiveMetric
  class ReportViewModelTest < ActiveSupport::TestCase

    class TestReportViewModel < ActiveMetric::ReportViewModel

      table :table1 do
        column "header 1", :field1
        column "header 2", :field2, 2
        column "header 3", :field3
      end

      table :table2 do
        column "header 1", :field1
        column "header 2", :field2
      end

    end

    test "can instantiate a view model" do
      rvm = TestReportViewModel.new
      rvm.add_table :table1, subjects
      table = rvm.tables.first

      expected_headers = ["header 1", "header 2", "header 3"]
      assert_equal expected_headers, table.headers

      expected_cells = ["name",2.8345, 3]
      table.rows.each do |row|
        assert_equal expected_cells, row.cells.map(&:value)
      end

    end

    test "cannot add a table that does not exist" do
      rvm = TestReportViewModel.new
      assert_raise ReportViewModel::TableDoesNotExist do
        rvm.add_table :bad_table, subjects
      end
    end

    test "can have multiple tables" do
      rvm = TestReportViewModel.new
      rvm.add_table :table1, subjects
      rvm.add_table :table2, subjects
      rvm.add_table :table1, subjects

      table1_headers  = ["header 1", "header 2", "header 3"]
      table2_headers = ["header 1", "header 2"]

      assert_equal table1_headers, rvm.tables[0].headers
      assert_equal table2_headers, rvm.tables[1].headers
      assert_equal table1_headers, rvm.tables[2].headers

      table1_data = ["name",2.8345, 3]
      table2_data = ["name",2.8345]
      table3_data = ["name",2.8345, 3]

      assert_table_data table1_data, rvm.tables[0]
      assert_table_data table2_data, rvm.tables[1]
      assert_table_data table3_data, rvm.tables[2]
    end

    def assert_table_data(data, table)
      table.rows.each do |row|
        assert_equal data, row.cells.map(&:value)
        assert_equal "1", row.row_id
      end
    end

    def subjects
      subject = create_row_data(field1: "name",
                                field2: 2.8345,
                                field3: 3)

      subject.stubs(:to_param).returns("1")
      [subject]
    end

    def create_row_data(values)
      row_data = mock
      values.each do |key,value|
        row_data.stubs(key).returns(value)
      end
      row_data
    end

  end
end