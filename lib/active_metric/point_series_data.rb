module ActiveMetric
  class PointSeriesData < SeriesData

    field :data, :type => Array, :default => []

    delegate :size, :to => :data

    def push(value)
      push_all(:data, [value])
    end

    def pop
      super(:data,1)
    end

  end
end