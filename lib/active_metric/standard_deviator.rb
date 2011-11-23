module ActiveMetric
  class StandardDeviator
    attr_reader :count, :sum, :sum_of_squares, :standard_deviation, :property

    def initialize(property)
      @count = 0
      @property = property
      @sum = 0
      @sum_of_squares = 0
      @standard_deviation = 0.0
    end

    def calculate(measurement)
      @count +=1
      value = measurement.send(property)
      @sum += value
      @sum_of_squares += value * value
    end

    def standard_deviation
      mean         = sum.to_f / count
      mean_squares = sum_of_squares.to_f / count
      @standard_deviation   = Math.sqrt(mean_squares - (mean * mean))
    end
  end
end
