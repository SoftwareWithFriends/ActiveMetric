module ActiveMetric
  class Report
    include Mongoid::Document

    has_many :subjects, :class_name => "ActiveMetric::Subject", :dependent => :destroy

    def name
      "report"
    end

    def series
      subjects.map(&:series).flatten
    end

  end
end
