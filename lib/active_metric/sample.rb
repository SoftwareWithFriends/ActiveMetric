module ActiveMetric
  class Sample
    include Mongoid::Document

    belongs_to :samplable, :polymorphic => true

    embeds_many :stats, :class_name => "ActiveMetric::Stat", :as => :calculable, :cascade_callbacks => true

    field :interval,          :type => Integer, :default => nil
    field :start_time,        :type => Integer
    field :end_time,          :type => Integer
    field :timestamp,         :type => Integer
    field :measurement_count, :type => Float,   :default => 0.0
    field :sum,               :type => Integer, :default => 0

    def initialize(*args)
      super(*args)
      if stats.empty?
        self.class.stats_defined.each do |prototype|
          self.stats << prototype[:klass].new(prototype[:name_of_stat])
        end
      end
    end

    def calculate(measurement)
      self.start_time ||= measurement.timestamp
      if within_interval?(measurement)

        update_time(measurement)
        update_stats(measurement)
        return self
      end

      complete
      new_sample.calculate(measurement)
    end

    def complete
      self.stats.each do |statistic|
        statistic.complete
      end
      self.safely.save!
    end

    def time_range
      end_time - start_time
    end

    def method_missing(method, *args)
      self.class.send(:define_method, method.to_sym) { get_stat_by_name(method) }
      get_stat_by_name(method)
    end

    def get_stat_by_name(name_of_stat)
      stats_by_name[name_of_stat] || raw_stat
    end

    def stats_by_name
      @stats_by_name ||= generate_stats_by_name
    end

    def stat_data
      data = []
      stats.each do |stat|
        data << {:name => stat.access_name, :axis => stat.axis}
      end
      data
    end

    private

    def generate_stats_by_name
      stat_name_hash = {}
      stats.each do |stat|
        stat_name_hash[stat.access_name] = stat
      end
      stat_name_hash
    end

    def within_interval?(measurement)
      return true unless self.interval
      (measurement.timestamp - self.start_time) < self.interval
    end

    def update_time(measurement)
      self.sum += measurement.timestamp
      self.measurement_count += 1
      self.end_time           = measurement.timestamp
      self.timestamp          = self.sum / self.measurement_count
    end

    def update_stats(measurement)
      self.stats.each do |stat|
        stat.calculate(measurement)
      end
    end

    def new_sample
      self.class.create(:samplable => self.samplable, :interval => interval)
    end

    def self.stats_defined
      @stats_defined ||= []
    end

    def self.custom_stats_defined
      @custom_stats_defined ||= []
    end

    def self.stat(property, stats_to_define = [:min, :mean, :max, :eightieth, :ninety_eighth])
      stats_to_define.each do |stat|
        self.stats_defined << {:klass => Stat.class_for(stat), :name_of_stat => property }
      end
    end

    def self.custom_stat(name_of_stat, value_type,default = nil, axis = -1, &block)
      self.stats_defined << {:name_of_stat => name_of_stat,
                             :klass => Stat.create_custom_stat(name_of_stat,
                                                               value_type,
                                                               default,
                                                               axis,
                                                               block)}
    end

    def raw_stat
      r_stat = Stat.new(:value)
      Rails.logger.error "\n\nGenerating new raw stat #{r_stat.inspect}"
      r_stat
    end
  end
end