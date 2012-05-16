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

    def subjects_by_type
      subjects_type = {}
      subjects.each do |subject|
        type = subject.class.name.split("::").last.underscore
        subjects_type[type] ||= []
        subjects_type[type] << subject
      end
      subjects_type
    end

    def method_missing(method, *args)
      super(method, *args) unless method.to_s.match /subjects$/
      subject_class = "#{self.class.parent}::#{method.to_s.classify}".constantize
      subject_class.where(report_id: id).all
    end

  end
end
