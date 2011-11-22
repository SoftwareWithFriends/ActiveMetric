module ActiveMetric
  class Subject
    include Mongoid::Document
    include Mongoid::Timestamps

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

    def interval_samples
      samples.where(:interval => self.class.interval_length)
    end

    def calculate(measurement)
      summary.calculate(measurement)
      @current_sample = current_sample.calculate(measurement)
      reservoir.fill(measurement)
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

    def series
      generate_series_data
      self.save!
      self.series_data.values
    end

    def generate_series_data
      self.series_data ||= {}
      @start_time = summary.start_time

      summary.stat_data.each do |datum|
        next if datum[:axis] < 0
        data = []
        name = datum[:name]
        axis = datum[:axis]

        if self.series_data[name]
          sample_skip = self.series_data[name][:data].size
        else
          sample_skip = 0
        end
        Rails.logger.info "\nskipping #{sample_skip}\n"

        interval_samples.skip(sample_skip).each do |sample|
          stat = sample.stats_by_name[datum[:name]]
          data << [time(sample.timestamp), stat.value] if sample.timestamp && @start_time
        end

        if self.series_data[name]
          self.series_data[name][:data].concat data
        else
          self.series_data[name] = {:name => name, :data => data, :yAxis => axis}
        end
      end
    end

    def time(sample_time)
      ((sample_time - @start_time)).to_i
    end

  end
end
