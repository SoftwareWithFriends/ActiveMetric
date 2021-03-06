module ActiveMetric
  class Axis
    include Mongoid::Document

    embedded_in :graph_view_model, :class_name => "ActiveMetric::GraphViewModel"

    field :label, default: "units", type: String
    field :min
    field :index, default: 0, type: Integer
  end
end