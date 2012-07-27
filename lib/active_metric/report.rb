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

    def min
      0
    end

    def view_model
      nil
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
      subject_class = subject_class_for_report(method)
      subject_class ? subject_class.where(report_id: id).all :
          super(method, *args)
    end

    def subject_class_for_report(method)
      return "#{self.class.parent}::#{method.to_s.classify}".constantize if method.to_s.match /subjects$/
    rescue NameError
    end

  end
end
