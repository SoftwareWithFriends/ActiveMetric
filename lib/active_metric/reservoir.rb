module ActiveMetric
  class Reservoir

    attr_reader :size, :current_round, :false_count, :true_count
    attr_accessor :measurements

    THRESHOLD = 10

    def initialize(size)
      @size = size
      @measurements = []
      @current_index = 0
      @sorted_measurements = {}
      @false_count=  0
      @true_count = 0
      @current_round = 1
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
      return 0 unless size_for_calculation > 0
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
      chance = (@current_index.to_f / size_for_calculation.to_f) * 100
      replace = rand(chance) <= (100.0 / @current_round.to_f)
      replace ? @true_count +=1 : @false_count += 1
      replace
    end

    def simulate_chance(chance)
      rand + (1-chance) >= 1
    end

    def update_index
      if @current_index >= size - 1
        @current_index = 0
        @current_round+= 1
        @true_count = 0
        @false_count = 0

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