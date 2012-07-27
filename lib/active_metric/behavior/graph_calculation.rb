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
          if stat_meta_data[stat.access_name]
            graph_view_model.series_for(stat.access_name.to_s).push([time(sample.timestamp), stat.value]) if sample.timestamp && start_time
          end
        end
      end

      self.save!
    end

    def initialize_graph_view_model
      GraphViewModel.create_from_stat_meta_data(stat_meta_data.values, name: name)
    end

    def remove_last_sample_from_cache
      graph_view_model.series_data.each do |series|
        series.pop
      end
    end

    def remaining_interval_samples
      sample_skip = graph_view_model.size
      interval_samples[sample_skip..-1]
    end

    def time(sample_time)
      ((sample_time - start_time)).to_i
    end

    def stat_meta_data
      self.class.sample_type.new.stat_meta_data
    end

    def start_time
      @start_time ||= summary.start_time
    end

    def debug(message)
      Rails.logger.error "DEBUGAM #{self.name} #{message}"
    end

  end
end