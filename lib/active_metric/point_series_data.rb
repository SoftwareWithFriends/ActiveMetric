module ActiveMetric
  class PointSeriesData < SeriesData

    field :data, :type => Array, :default => []

    delegate :size, :to => :data

    def push_data(value)
      push_all(:data, [value])
    end

    def pop_data(data_to_pop = 1)
      pop(:data,data_to_pop)
    end

  end
end