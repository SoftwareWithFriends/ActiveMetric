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
      mean         = sum.to_f / count
      mean_squares = sum_of_squares.to_f / count
      self.value   = Math.sqrt(mean_squares - (mean * mean))
      super
    end

  end

  ##This could be incorrect.
  #class WelfordStandardDeviation < Stat
  #  field :value, :type => Float,   :default => 0
  #
  #  field :mean,  :type => Float, :default => 0
  #  field :sum,   :type => Float, :default => 0
  #  field :count, :type => Integer, :default => 0
  #
  #  def calculate(measurement)
  #    self.count +=1
  #    temp = sum
  #    value = measurement.send(self.property)
  #    self.mean += (value - temp) / count
  #    self.sum  += (value - temp) * (value - mean)
  #  end
  #
  #  def complete
  #    self.value = Math.sqrt(sum / (count))
  #    super
  #  end
  #end
end