module ActiveMetric
  class Subject
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :report, :class_name => "ActiveMetric::Report", :polymorphic => true
    has_many :samples, :class_name => "ActiveMetric::Sample", :as => :samplable
    field :name, :type => String

    def summary
      @summary ||= samples.where(:interval => nil).first ||
                   sample_type.create(:samplable => self,
                                      :interval   => nil)
    end

    def interval_samples
      samples.where(:interval => interval_length)
    end

    def calculate(measurement)
      summary.calculate(measurement)
      @current_sample = current_sample.calculate(measurement)
    end

    def complete
      self.summary.complete
      self.current_sample.complete
      self.safely.save
    end

    def current_sample
      @current_sample ||= interval_samples.last ||
                          sample_type.create(:samplable => self,
                                             :interval   => interval_length)
    end

    def headers_for_table
      headers = []
      summary.stats.each do |stat|
        headers << stat.name
      end

    end

    private

    def interval_samples_query
      samples.where(:interval => interval_length)
    end

    def sample_type
      @@sample_type ||= ActiveMetric::Sample
    end

    def interval_length
      @@interval_length ||= 5
    end

    def self.calculated_with(sample_type, interval_length)
      @@sample_type = sample_type
      @@interval_length = interval_length
    end

  end
end
