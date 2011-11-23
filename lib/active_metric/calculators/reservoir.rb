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
      return 0 unless size_for_calculation > 0
      measurements_for_metric = sorted_measurements_for(metric)
      index = size_for_calculation * percentile
      measurements_for_metric[index].send(metric.to_sym)
    end
    
    def calculate_standard_deviation(metric)
      return 0 unless size_for_calculation > 0
      measurements_for_metric = sorted_measurements_for(metric)
      standard_deviation_on(measurements_for_metric, metric)  
    end

    private
    
    def standard_deviation_on(list, metric)
      sd = StandardDeviator.new(metric)
      list.each do |measurement|
        sd.calculate measurement
      end
      sd.standard_deviation
    end
    
    def sorted_measurements_for(metric)
      @sorted_measurements[metric.to_sym] ||= measurements.sort_by(&metric.to_sym)
    end

    def update_reservoir_at_current_index(measurement)
      @measurements[@current_index] = measurement
      @sorted_measurements.clear
    end

    def should_replace_at_current_index?
      #chance = (@current_index.to_f / size_for_calculation.to_f) * 100
      #replace = rand(chance) <= (100.0 / @current_round.to_f)
      true
    end

    def simulate_chance(chance)
      rand + (1-chance) >= 1
    end

    def update_index
      if @current_index >= size - 1
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