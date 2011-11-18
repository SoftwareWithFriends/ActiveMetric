module ActiveMetric

  class Measurement
    include Mongoid::Document

    #belongs_to :report, :class => "ActiveMetric::Report"
    field :timestamp, :type => Integer

    def time
      Time.at((timestamp.to_i / 1000).to_i).to_datetime
    end
  end
end
