module ActiveMetric
  class SeriesData
    include Mongoid::Document

    embedded_in :graph_view_model, :class_name => "ActiveMetric::GraphViewModel"

    field :label
    field :y_axis, :default => 0
    field :x_axis, :default => 0
    field :approximation, :default => "high"
    field :visible, :default => true

    def self.from_meta_data(meta_data)
      series               = self.new(label: meta_data[:name].to_s)
      series.x_axis        = meta_data[:x_axis]  if meta_data[:x_axis]
      series.y_axis        = meta_data[:axis]  if meta_data[:axis]
      series.approximation = meta_data[:approximation]  if meta_data[:approximation]
      series.visible       = meta_data[:visible]  if meta_data[:visible]
      series
    end

  end
end