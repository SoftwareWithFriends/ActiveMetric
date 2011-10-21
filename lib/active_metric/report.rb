module ActiveMetric
  class Report
    include Mongoid::Document

    has_many :subjects, :class_name => "ActiveMetric::Subject"

    def name
      "report"
    end

  end
end
