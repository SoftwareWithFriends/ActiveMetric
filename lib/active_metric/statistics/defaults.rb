module ActiveMetric
  class Min < Stat
    field :value, :type => Float, :default => (1 << 64)
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
      self.value = (self.sum / self.count).to_f
      super
    end
  end

  class Derivative < Stat
    field :first
    field :last

    def calculate(measurement)
      self.last  = (measurement.send(self.property))
      self.first ||= self.last
    end

    def complete
      self.value = (self.last - self.first).to_f / sample_duration_in_seconds
      super
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

end