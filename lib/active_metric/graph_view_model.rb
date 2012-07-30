module ActiveMetric

  class Axis
    include Mongoid::Document

    JAVA_SCRIPT_NO_OPTION = "null"

    field :label, default: "units"
    field :min, default: JAVA_SCRIPT_NO_OPTION
    field :index, default: 0
  end


  class GraphViewModel
    include Mongoid::Document

    belongs_to :subject, :class_name => "ActiveMetric::Subject", :polymorphic => true
    index({:subject_id => 1},{:background => true})
    field :name
    embeds_many :series_data, :class_name => "ActiveMetric::SeriesData"
    embeds_many :axis, as: :y_axises, class_name: "ActiveMetric::Axis"
    #embeds_many :axis, as: :x_axises, class_name: "ActiveMetric::Axis"

    def self.create_from_meta_data(axises_defined,stats_defined, options = {})
      graph = self.new(options)
      graph.populate_axises(axises_defined)
      graph.populate_series(stats_defined)
      graph.save!
      graph
    end

    def populate_axises(axises_defined)
      axises_defined.each do |axis_options|
        y_axises[axis_options[:index]] = Axis.new(axis_options)
      end
    end

    def populate_series(stats_defined)
      stats_defined.each do |stat_definition|
        series_data << PointSeriesData.from_stat_definition(stat_definition) if stat_definition.graphable?
      end
    end

    def series_for(label)
      series_data.select{|series| series.label.eql? label}.first
    end

    def size
      return 0 unless series_data.size > 0
      series_data.first.size
    end
  end


end