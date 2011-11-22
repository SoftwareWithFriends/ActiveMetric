module ActiveMetric
  class StandardDeviation < Stat
    field :value,          :type => Float,   :default => 0

    field :sum,            :type => Integer, :default => 0
    field :sum_of_squares, :type => Integer, :default => 0
    field :count,          :type => Integer, :default => 0

    def calculate(measurement)
      self.count +=1
      value = measurement.send(self.property)
      self.sum += value
      self.sum_of_squares += value * value
    end

    def complete
      mean         = sum / count
      mean_squares = sum_of_squares / count
      self.value   = Math.sqrt(mean_squares - (mean * mean))
      super
    end

  end
end