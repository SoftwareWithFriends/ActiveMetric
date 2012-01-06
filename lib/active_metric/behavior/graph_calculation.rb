module ActiveMetric
  module GraphCalculation
    #REQUIRES SUMMARY AND INTERVAL SAMPLES AND SERIES DATA

    def series
      update_all_series
      self.save!
      series_data.values
    end

    def update_all_series
      self.series_data ||= initialize_cache

      remaining_interval_samples.each do |sample|
        sample.stats.each do|stat|
          if stat_meta_data[stat.access_name]
            debug "adding stat data #{time(sample.timestamp)}, #{stat.value}"
            series_data[stat.access_name.to_s]["data"] << [time(sample.timestamp), stat.value] if sample.timestamp && start_time
          end
        end
      end
    end

    def initialize_cache
      empty_cache = {}
      stat_meta_data.values.each do |meta_data|
        axis = meta_data[:axis]
        next if axis < 0
        name = meta_data[:name].to_s
        empty_cache[name] = {"name" => name, "data" => [], "yAxis" => axis}
      end
      empty_cache
    end

    def remaining_interval_samples
      sample_skip = size_of_cache_data
      debug "sample skip: #{sample_skip}"
      debug "interval samples: #{interval_samples.count}"
      interval_samples.skip(sample_skip)
    end

    def time(sample_time)
      ((sample_time - start_time)).to_i
    end

    def stat_meta_data
      summary.stat_meta_data
    end

    def start_time
      @start_time ||= summary.start_time
    end

    def size_of_cache_data
      if series_data.first
        sample_skip = series_data.values.first["data"].size
        debug "has data cache"
      else
        sample_skip = 0
      end
      sample_skip
    end

    def debug(message)
      Rails.logger.info "DEBUG #{self.name} #{message}"
    end

  end
end