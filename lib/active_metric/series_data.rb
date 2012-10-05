module ActiveMetric
  class SeriesData
    include Mongoid::Document

    embedded_in :graph_view_model, :class_name => "ActiveMetric::GraphViewModel"

    field :label
    field :y_axis, :default => 0
    field :x_axis, :default => 0
    field :approximation, :default => "high"
    field :visible, :default => true

    def self.from_stat_definition(stat_definition)
      series               = self.new(label: stat_definition.access_name.to_s)
      options = stat_definition.options

      series.x_axis        = options[:x_axis]        if options[:x_axis]
      series.y_axis        = options[:axis]          if options[:axis]
      series.approximation = options[:approximation] if options[:approximation]
      series.visible       = options[:visible]       if options[:visible]

      series
    end

  end
end