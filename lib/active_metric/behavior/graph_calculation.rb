module ActiveMetric
  module GraphCalculation
    #REQUIRES SUMMARY AND INTERVAL SAMPLES AND SERIES DATA
    MONGO_MAX_LIMIT = (1 << 31) - 1

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

    def graph_view_model_starting_at(index)
      GraphViewModel.where(subject_id: id).slice("series_data.data" => [index, MONGO_MAX_LIMIT]).first
    end

    def update_graph_model(interval_sample)
      pop_necessary_samples(interval_sample)
      interval_sample.stats.each do |stat|
        series = graph_view_model.series_for(stat.access_name.to_s)
        series.push_data([time(interval_sample.timestamp), stat.value]) if series && interval_sample.timestamp && start_time
      end

      self.save!
    end

    def pop_necessary_samples(interval_sample)
      data_to_pop = calculate_data_to_pop(interval_sample)
      pop_from_series(data_to_pop) if data_to_pop > 0
    end

    def calculate_data_to_pop(interval_sample)
      incoming_index = interval_sample.sample_index
      next_index = graph_view_model.size
      next_index - incoming_index
    end

    def pop_from_series(data_to_pop)
      graph_view_model.series_data.each do |series|
        series.pop_data(data_to_pop)
      end
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

    def time(sample_time)
      ((sample_time - start_time)).to_i
    end

    def start_time
      @start_time ||= summary.start_time
    end

    def debug(message)
      ActiveMetric.logger.error "DEBUGAM #{self.name} #{message}"
    end

  end
end