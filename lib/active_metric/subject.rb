module ActiveMetric
  class Subject
    include Mongoid::Document
    include Mongoid::Timestamps
    include GraphCalculation

    belongs_to :report, :class_name => "ActiveMetric::Report", :polymorphic => true
    has_many :samples, :class_name => "ActiveMetric::Sample", :as => :samplable, :dependent => :destroy

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
      @summary ||= samples.where(:interval => nil).first ||
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

    def interval_samples
      samples.reject{|s| s.interval.nil?}.sort_by(&:timestamp)
    end

    def calculate(measurement)
      summary.calculate(measurement)
      returned_sample = current_sample.calculate(measurement)
      update_subject_calculators(measurement)
      update_current_sample(returned_sample) if is_new_sample?(returned_sample)
    end

    def update_current_sample(returned_sample)
      @current_sample = returned_sample
      self.complete
    end

    def is_new_sample?(returned_sample)
      returned_sample != @current_sample
    end

    def update_subject_calculators(measurement)
      reservoir.fill(measurement)
      standard_deviators.values.each { |sd| sd.calculate(measurement) }
    end

    def complete
      self.summary.complete
      self.current_sample.complete
      self.update_graph_model

      self.save!
    end

    def current_sample
      @current_sample ||= interval_samples.last ||
          self.class.sample_type.new(:samplable => self,
                                     :interval   => self.class.interval_length)
    end

    def headers_for_table
      headers = []
      summary.stats.each do |stat|
        headers << stat.name
      end
    end

    def graphable_stats
      return {} unless samples.any?
      samples.first.stat_meta_data
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
