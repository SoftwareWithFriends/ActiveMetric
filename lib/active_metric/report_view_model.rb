module ActiveMetric
  class ReportViewModel
    attr_reader :tables

    class TableDoesNotExist < Exception; end

    def initialize
      @tables = []
    end

    def self.table(table_name)
      table_templates[table_name] =  @current_template = TableTemplate.new(table_name)
      yield
    end

    def self.table_templates
      @table_templates ||= {}
    end

    def self.column(header, field, precision = 0)
      @current_template.add_column(header,field,precision)
    end

    def add_table(table_name, subjects, options = {})
      template = self.class.table_templates[table_name]
      raise TableDoesNotExist unless template
      tables << TableViewModel.new(template, subjects, options)
    end

    class TableTemplate
      attr_reader :name
      attr_reader :columns

      def initialize(name)
        @name = name
        @columns = []
      end

      def add_column(header,field, precision)
        @columns << ColumnTemplate.new(header, field, precision)
      end

      def headers
        columns.map(&:header)
      end

    end

    class ColumnTemplate
      attr_reader :header
      attr_reader :field
      attr_reader :precision

      def initialize(header, field, precision)
        @header = header
        @field = field
        @precision = precision
      end

    end


    class TableViewModel
      attr_reader :title
      attr_reader :rows
      attr_reader :headers

      def initialize(template, subjects, options)
        @title = options[:title]
        @rows = []
        @headers = template.headers
        subjects.each do |subject|
          @rows << RowViewModel.new(subject.summary, template.columns, subject.to_param)
        end
      end
    end

    class RowViewModel
      attr_reader :cells
      attr_reader :row_id

      def initialize(row_data, columns, row_id)
        @cells = []
        @row_id = row_id
        columns.each do |col|
          value = row_data.send(col.field).value
          cells << CellViewModel.new(value, col.precision)
        end
      end
    end

    class CellViewModel
      attr_reader :value
      attr_reader :precision

      def initialize(value, precision)
        @value = value
        @precision = precision
      end
    end

  end
end