module ActiveMetric
  module CalculatesDerivative

    def derivative_from_seed_measurement(first, last)
      duration_from_seed_measurement = calculable.duration_from_previous_sample_in_seconds
      calculate_derivative(first, last, duration_from_seed_measurement)
    end

    def calculate_derivative(first, last, duration)
      if duration > 0
        (last - first).to_f / duration
      else
        0
      end
    end

  end
end