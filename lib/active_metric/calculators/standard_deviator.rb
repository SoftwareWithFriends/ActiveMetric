module ActiveMetric
  class StandardDeviator
    attr_reader :count, :sum, :sum_of_squares, :property

    def initialize(property)
      @count = 0
      @property = property
      @sum = 0
      @sum_of_squares = 0
      @standard_deviation = 0.0
    end

    def calculate(measurement)
      @standard_deviation = nil
      @count +=1
      value = measurement.send(property)
      @sum += value
      @sum_of_squares += value * value
    end

    def standard_deviation
      @standard_deviation ||= calculate_standard_deviation
    end

    def calculate_standard_deviation
      diff = mean_squares - (mean * mean)
      Math.sqrt(diff)
    end

    def mean
      sum.to_f / count
    end

    def mean_squares
      sum_of_squares.to_f / count
    end

  end
end
