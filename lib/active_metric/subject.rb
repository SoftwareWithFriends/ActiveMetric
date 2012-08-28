module ActiveMetric
  class Subject
    include Mongoid::Document
    include Mongoid::Timestamps
    include GraphCalculation

    belongs_to :report, :class_name => "ActiveMetric::Report", :polymorphic => true
    has_one :samples, :class_name => "ActiveMetric::Sample", :as => "samplable", :dependent => :delete
    has_one :graph_view_model, :class_name => "ActiveMetric::GraphViewModel", :dependent => :delete

    field :name, :type => String

    index({:report_id => -1},{:background => true})

    def method_missing(method, *args)
      self.class.send(:define_method, method.to_sym) { value_from_summary(method) }
      value_from_summary(method)
    end

    def value_from_summary(method)
      ret_value = summary.send(method)
      if ret_value.is_a?(Stat)
        return ret_value.value
      end
      ret_value
    end

    def summary
      @summary ||= ActiveMetric::Sample.where(:samplable => to_param, :interval => nil).first ||
          self.class.summary_type.create(:samplable => self,
                                         :interval   => nil)
    end

    def reservoir
      @reservoir ||= Reservoir.new(2000)
    end

    def standard_deviators
      @standard_deviators ||= {}
    end

    def ensure_standard_deviator_for(property)
      standard_deviators[property] ||= StandardDeviator.new(property)
    end

    def calculate(measurement)
      summary.calculate(measurement)
      returned_sample = current_sample.calculate(measurement)
      update_current_sample(returned_sample) if is_new_sample?(returned_sample)
      update_subject_calculators(measurement)
    end

    def update_current_sample(returned_sample)
      self.complete
      @current_sample = returned_sample
    end

    def is_new_sample?(returned_sample)
      returned_sample != @current_sample
    end

    def update_subject_calculators(measurement)
      reservoir.fill(measurement)
      standard_deviators.values.each { |sd| sd.calculate(measurement) }
    end

    def complete
      summary.complete
      current_sample.complete
      update_graph_model([current_sample])

      save!
    end

    def current_sample
      @current_sample ||= self.class.sample_type.new(:samplable => self,
                                                     :interval   => self.class.interval_length)
    end

    def self.sample_type
      nil
    end

    def self.interval_length
      raise
    end

    def self.calculated_with(sample_type, interval_length, summary_type = sample_type)
      instance_eval %Q|
        def self.sample_type
          #{sample_type}
        end

        def self.interval_length
          #{interval_length}
        end

        def self.summary_type
          #{summary_type}
        end
      |
    end



  end
end
