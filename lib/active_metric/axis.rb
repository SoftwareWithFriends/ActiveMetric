module ActiveMetric
  class Axis
    include Mongoid::Document

    embedded_in :graph_view_model, :class_name => "ActiveMetric::GraphViewModel"

    JAVA_SCRIPT_NO_OPTION = "null"

    field :label, default: "units", type: String
    field :min, default: JAVA_SCRIPT_NO_OPTION
    field :index, default: 0, type: Integer
  end
end