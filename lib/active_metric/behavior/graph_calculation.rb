module ActiveMetric
  module GraphCalculation
    #REQUIRES SUMMARY AND INTERVAL SAMPLES AND SERIES DATA
    def series
      update_all_series
      self.save!
      self.series_data.values
    end

    def update_all_series
      self.series_data ||= {}

      remaining_interval_samples = get_remaining_interval_samples

      stat_data_for_series.each do |meta_data|
        axis = meta_data[:axis]
        next if axis < 0
        name = meta_data[:name].to_s
        update_series_for_stat(axis, name, remaining_interval_samples)
      end
    end

    def update_series_for_stat(axis, name, remaining_interval_samples)
      data = calculate_series_data(name, remaining_interval_samples)
      update_series_data(axis, data, name)
    end

    def get_remaining_interval_samples
      sample_skip = size_of_cache_data
      interval_samples.skip(sample_skip)
    end

    def calculate_series_data(name, remaining_interval_samples)
      data = []
      remaining_interval_samples.each do |sample|
        stat = sample.stats_by_name[name.to_sym]
        data << [time(sample.timestamp), stat.value] if sample.timestamp && start_time
      end
      data
    end

    def update_series_data(axis, data, name)
      if series_data[name]
        series_data[name]["data"].concat data
      else
        series_data[name] = {"name" => name, "data" => data, "yAxis" => axis}
      end
    end

    def time(sample_time)
      ((sample_time - start_time)).to_i
    end

    def stat_data_for_series
      summary.stat_data
    end

    def start_time
      @start_time ||= summary.start_time
    end

    def size_of_cache_data
      if series_data.first
        sample_skip = series_data.first[1]["data"].size
      else
        sample_skip = 0
      end
      sample_skip
    end

  end
end