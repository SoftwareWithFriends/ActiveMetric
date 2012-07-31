module ActiveMetric
  module GraphCalculation
    #REQUIRES SUMMARY AND INTERVAL SAMPLES AND SERIES DATA

    def self.included(klass)
      klass.has_one :graph_view_model,
                    :class_name => "ActiveMetric::GraphViewModel", :autosave => true
      klass.after_initialize do
        self.graph_view_model ||= initialize_graph_view_model
      end
    end

    def series
      return nil unless attributes["series_data"]
      attributes["series_data"].values
    end

    def has_graph_data
      true
    end

    def update_graph_model
      remove_last_sample_from_cache

      remaining_interval_samples.each do |sample|
        sample.stats.each do|stat|
          series = graph_view_model.series_for(stat.access_name.to_s)
          series.push_data([time(sample.timestamp), stat.value]) if series && sample.timestamp && start_time
        end
      end

      self.save!
    end

    def initialize_graph_view_model
      if self.class.sample_type
        axises_defined = self.class.sample_type.axises_defined
        stats_defined = self.class.sample_type.stats_defined
      else
        axises_defined = []
        stats_defined = []
      end
      GraphViewModel.create_from_meta_data(axises_defined, stats_defined, name: name)
    end

    def remove_last_sample_from_cache
      graph_view_model.series_data.each do |series|
        series.pop_data
      end
    end

    def remaining_interval_samples
      sample_skip = graph_view_model.size
      interval_samples[sample_skip..-1]
    end

    def time(sample_time)
      ((sample_time - start_time)).to_i
    end

    def start_time
      @start_time ||= summary.start_time
    end

    def debug(message)
      Rails.logger.error "DEBUGAM #{self.name} #{message}"
    end

  end
end