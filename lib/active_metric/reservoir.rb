module ActiveMetric
  class Reservoir

    attr_reader :size
    attr_accessor :measurements

    def initialize(size)
      @size = size
      @measurements = []
      @current_index = 0
      @sorted_measurements = {}
    end

    def fill(measurement)
      if reservoir_full?
        update_reservoir_at_current_index(measurement) if should_replace_at_current_index?
      else
        update_reservoir_at_current_index(measurement)
      end
      update_index
    end

    def calculate_percentile(percentile, metric)
      @sorted_measurements[metric.to_sym] ||= measurements.sort_by(&metric.to_sym)
      index = size_for_calculation * percentile
      info("index for #{percentile}: #{index} with total collection #{measurements.size} and sub collection #{@sorted_measurements[metric.to_sym].size}")
      @sorted_measurements[metric.to_sym][index].send(metric.to_sym)
    end

    private

    def info(string_to_log)
      Rails.logger.info string_to_log if Rails
    end

    def update_reservoir_at_current_index(measurement)
      @measurements[@current_index] = measurement
      @sorted_measurements.clear
    end

    def should_replace_at_current_index?
      rand(@current_index + 1) == 0
    end

    def update_index
      if @current_index == size - 1
        @current_index = 0
      else
        @current_index+= 1
      end
    end

    def size_for_calculation
      reservoir_full? ? size : measurements.size
    end

    def reservoir_full?
      size == measurements.size
    end
  end
end