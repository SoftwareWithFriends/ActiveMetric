module ActiveMetric
  class Axis
    include Mongoid::Document

    JAVA_SCRIPT_NO_OPTION = "null"

    field :label, default: "units"
    field :min, default: JAVA_SCRIPT_NO_OPTION
    field :index, default: 0
  end
end