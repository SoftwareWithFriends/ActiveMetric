module ActiveMetric
  class Reservoir

    attr_reader :metric, :size
    attr_accessor :measurements

    def initialize(metric, size)
      @metric = metric
      @size = size
      @measurements = []
      @current_index = 0
    end

    def fill(measurement)
      @sorted_measurements = nil
      if reservoir_full?
        update_reservoir_at_current_index(measurement) if should_replace_at_current_index?
      else
        update_reservoir_at_current_index(measurement)
      end
      update_index
    end

    def calculate_percentile(percentile)
      @sorted_measurements ||= measurements.sort_by(&@metric)
      index = size_for_calculation * percentile
      @sorted_measurements[index].send(@metric)
    end

    private

    def update_reservoir_at_current_index(measurement)
      @measurements[@current_index] = measurement
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