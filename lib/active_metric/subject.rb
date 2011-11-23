module ActiveMetric
  class Subject
    include Mongoid::Document
    include Mongoid::Timestamps
    include GraphCalculation

    belongs_to :report, :class_name => "ActiveMetric::Report", :polymorphic => true
    has_many :samples, :class_name => "ActiveMetric::Sample", :as => :samplable, :dependent => :destroy
    field :name, :type => String
    field :series_data, :type => Hash

    def summary
      @summary ||= samples.where(:interval => nil).first ||
          self.class.sample_type.create(:samplable => self,
                                        :interval   => nil)
    end

    def reservoir
      @reservoir ||= Reservoir.new(2000)
    end

    def standard_deviators
      @standard_deviators ||={}
    end

    def ensure_standard_deviator_for(property)
      standard_deviators[property] ||= StandardDeviator.new(property)
    end

    def interval_samples
      samples.where(:interval => self.class.interval_length)
    end

    def calculate(measurement)
      summary.calculate(measurement)
      @current_sample = current_sample.calculate(measurement)
      reservoir.fill(measurement)
      standard_deviators.values.each {|sd| sd.calculate(measurement)}
    end

    def complete
      self.summary.complete
      self.current_sample.complete
      self.safely.save
    end

    def current_sample
      @current_sample ||= interval_samples.last ||
          self.class.sample_type.create(:samplable => self,
                                        :interval   => self.class.interval_length)
    end

    def headers_for_table
      headers = []
      summary.stats.each do |stat|
        headers << stat.name
      end

    end

    def interval_samples_query
      samples.where(:interval => self.class.interval_length)
    end

    def self.sample_type
      raise
    end

    def self.interval_length
      raise
    end

    def self.calculated_with(sample_type, interval_length)
      instance_eval %Q|
        def self.sample_type
          #{sample_type}
        end

        def self.interval_length
          #{interval_length}
        end
      |
    end



  end
end
