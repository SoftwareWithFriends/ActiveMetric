module ActiveMetric
  class StandardDeviation < Stat
    field :value,          :type => Float,   :default => 0
    def initialize(*args)
      super(*args)
    end
    def calculate(measurement)
      set_standard_deviator unless @have_set_standard_deviator
    end
    def complete
      set_standard_deviator unless @have_set_standard_deviator
      self.value = subject.standard_deviators[self.property].standard_deviation
      super
    end

    def set_standard_deviator
      @have_set_standard_deviator = true
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