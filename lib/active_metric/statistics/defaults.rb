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
      self.count += 1
      self.sum += measurement.send(self.property)
    end

    def complete
      self.value = (self.sum.to_f / self.count)
      super
    end
  end

  class Derivative < Stat
    include CalculatesDerivative
    field :first
    field :last

    def calculate(measurement)
      self.last = property_from(measurement)
      self.first ||= (property_from(calculable.seed_measurement) || self.last)
      self.value = derivative_from_seed_measurement(first,last)
    end

  end

  class Speed < Stat
    include CalculatesDerivative
    field :count, :type => Integer, :default => 0

    def calculate(measurement)
      self.count +=1
      self.value = derivative_from_seed_measurement(0,count)
    end
  end

  class Bucket < Stat
    field :value, :type => Hash, :default => {}

    MONGO_UNSAFE = /\.|\$/

    def calculate(measurement)
      key = property_from(measurement).to_s.gsub(MONGO_UNSAFE, "_")
      self.value[key] ||= 0
      self.value[key] += 1
    end
  end

  class LastDerivative < Derivative
    field :previous_timestamp

    def calculate(measurement)
      self.first = (self.last || property_from(calculable.seed_measurement) || property_from(measurement))

      duration = measurement.timestamp - (self.previous_timestamp || measurement.timestamp)
      self.previous_timestamp = measurement.timestamp

      self.last = property_from(measurement)
      self.value = calculate_derivative(first, last, duration)
    end

  end

  class Delta < Stat
    field :first

    def calculate(measurement)

      seed_value = property_from(calculable.seed_measurement)
      current_value = property_from(measurement)

      self.first ||= (seed_value || current_value)

      self.value = current_value - first
    end
  end

  class Sum < Stat
    def calculate(measurement)
      self.value += measurement.send(self.property)
    end
  end

  class Eightieth < Stat
    def calculate(measurement)
    end

    def complete
      self.value = subject.reservoir.calculate_percentile(0.8, self.property)
      super
    end
  end

  class NinetyEighth < Stat
    def calculate(measurement)
    end

    def complete
      self.value = subject.reservoir.calculate_percentile(0.98, self.property)
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