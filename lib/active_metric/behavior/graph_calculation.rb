module ActiveMetric
  module GraphCalculation
    #REQUIRES SUMMARY AND INTERVAL SAMPLES
    def series
      update_all_series
      self.save!
      self.series_data.values
    end

    def update_all_series
      self.series_data ||= {}

      stat_data_for_series.each do |datum|
        axis = datum[:axis]
        next if axis < 0
        name = datum[:name].to_s
        update_series_for_stat(axis, name)
      end
    end

    def update_series_for_stat(axis, name)
      sample_skip = get_current_sample_index(name)
      data = calculate_series_data(name, sample_skip)
      update_series_data(axis, data, name)
    end

    def get_current_sample_index(name)
      if series_data[name]
        sample_skip = series_data[name]["data"].size
      else
        sample_skip = 0
      end
      sample_skip
    end

    def calculate_series_data(name, sample_skip)
      data = []
      interval_samples.skip(sample_skip).each do |sample|
        stat = sample.stats_by_name[name.to_sym]
        data << [time(sample.timestamp), stat.value]
      end
      data
    end

    def update_series_data(axis, data, name)
      if series_data[name]
        series_data[name]["data"].concat data
      else
        series_data[name] = {:name => name, :data => data, :yAxis => axis}
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

  end
end