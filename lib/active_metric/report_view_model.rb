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

    def self.column(header, field, format_options = {})
      @current_template.add_column(header,field,format_options)
    end

    def add_table(table_name, table_data, options = {})
      template = self.class.table_templates[table_name]
      raise TableDoesNotExist unless template
      tables << TableViewModel.new(template, table_data, options)
    end

    class TableTemplate
      attr_reader :name
      attr_reader :columns

      def initialize(name)
        @name = name
        @columns = []
      end

      def add_column(header,field, format_options)
        @columns << ColumnTemplate.new(header, field, format_options)
      end

      def headers
        columns.map(&:header)
      end

    end

    class ColumnTemplate
      attr_reader :header
      attr_reader :field
      attr_reader :format_options

      def initialize(header, field, format_options)
        @header = header
        @field = field
        @format_options = format_options
      end

    end


    class TableViewModel
      attr_reader :title
      attr_reader :rows
      attr_reader :headers

      def initialize(template, table_data, options)
        @title = options[:title]
        @rows = []
        @headers = template.headers
        table_data.each do |row_data|
          @rows << RowViewModel.new(row_data, template.columns, row_data.to_param)
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
          value = row_data.send(col.field)
          cells << CellViewModel.new(value, col.format_options)
        end
      end

    end

    class CellViewModel
      attr_reader :value
      attr_reader :format_options

      def initialize(value, format_options)
        @value = value
        @format_options = format_options
      end
    end

  end
end