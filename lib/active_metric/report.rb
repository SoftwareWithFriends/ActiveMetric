module ActiveMetric
  class Report
    include Mongoid::Document

    field :test_run_id, :type => Integer
    has_many :subjects, :class_name => "ActiveMetric::Subject"

    def name
      "report"
    end

  end
end
