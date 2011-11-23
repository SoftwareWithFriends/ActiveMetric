module ActiveMetric
  class StandardDeviation < Stat
    field :value,          :type => Float,   :default => 0
    def initialize(*args)
      super(*args)
    end
    def calculate(measurement)
      set_standard_deviation unless @have_set_standard_deviation
    end
    def complete
      self.value = subject.standard_deviators[self.property].standard_deviation
    end

    def set_standard_deviation
      @have_set_standard_deviation = true
      subject.ensure_standard_deviator_for(self.property)
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