module ActiveMetric
  class GraphViewModel
    include Mongoid::Document

    belongs_to :subject, :class_name => "ActiveMetric::Subject", :polymorphic => true
    index({:subject_id => 1},{:background => true})

    field :name

    #embeds_many :axis, as: :x_axises, class_name: "ActiveMetric::Axis"
    #embeds_many :axis, as: :y_axises, class_name: "ActiveMetric::Axis"


    embeds_many :series_data, :class_name => "ActiveMetric::SeriesData"

    def self.create_from_stat_meta_data(stat_meta_data, options = {})
      graph = self.new(options)
      stat_meta_data.each do |meta_data|
        graph.series_data << PointSeriesData.from_meta_data(meta_data)
      end
      graph.save!
      graph
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