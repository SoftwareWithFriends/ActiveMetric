module ActiveMetric
  class Min < Stat
    field :value, :type => Float, :default => (1 << 62)
    def calculate(measurement)
      self.value = [self.value, measurement.send(self.property)].min
    end
  end

  class Max < Stat
    def calculate(measurement)
      self.value = [self.value, measurement.send(self.property)].max
    end
  end

  class Mean < Stat
    field :sum, :type => Float, :default => 0.0
    field :count, :type => Integer, :default => 0

    def calculate(measurement)
      self.count +=  1
      self.sum   +=  measurement.send(self.property)
    end

    def complete
      self.value = (self.sum.to_f / self.count)
      super
    end
  end

  class Derivative < Stat
    field :first
    field :last

    def calculate(measurement)
      self.last  = property_from_measurement(measurement)
      self.first ||= (property_from_measurement(calculable.seed_measurement) || self.last)
      duration_from_seed_measurement = calculable.duration_from_previous_sample_in_seconds
      self.value = calculate_derivative(first, last, duration_from_seed_measurement)
    end

    def calculate_derivative(first, last,duration)
      if duration > 0
        (last - first).to_f / duration
      else
        0
      end
    end

    def property_from_measurement(measurement)
      return nil unless measurement
      measurement.send(self.property)
    end

  end

  class LastDerivative < Derivative
    field :previous_timestamp

    def calculate(measurement)
      self.first = (self.last || property_from_measurement(calculable.seed_measurement) || property_from_measurement(measurement))

      duration = measurement.timestamp - (self.previous_timestamp || measurement.timestamp)
      self.previous_timestamp = measurement.timestamp

      self.last  = property_from_measurement(measurement)
      self.value = calculate_derivative(first, last, duration)
    end

  end

  class Sum < Stat
    def calculate(measurement)
      self.value +=  measurement.send(self.property)
    end
  end

  class Eightieth < Stat
    def calculate(measurement)
    end
    def complete
      self.value = subject.reservoir.calculate_percentile(0.8,self.property)
      super
    end
  end

  class NinetyEighth < Stat
    def calculate(measurement)
    end
    def complete
      self.value = subject.reservoir.calculate_percentile(0.98,self.property)
      super
    end
  end

  class Last < Stat
    def calculate(measurement)
      self.value = measurement.send(self.property)
    end
  end

  class Count < Stat
    def calculate(measurement)
      self.value += 1
    end
  end

  class TrueCount < Stat
    def calculate(measurement)
      self.value +=1 if measurement.send(self.property)
    end
  end

  class FalseCount < Stat
      def calculate(measurement)
        self.value +=1 unless measurement.send(self.property)
      end
  end

end