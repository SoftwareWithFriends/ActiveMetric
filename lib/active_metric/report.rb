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

    def bust_caches
      subjects.each do |subject|
        subject.series_data = nil
        subject.update_series_data
      end
    end

    def min
      0
    end

  end
end
