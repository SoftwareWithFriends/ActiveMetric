module ActiveMetric

  class Sample
    include Mongoid::Document

    belongs_to :samplable, :polymorphic => true, index: true

    embeds_many :stats, :as => :calculable

    attr_accessor :seed_measurement, :latest_measurement

    field :interval, :type => Integer, :default => nil
    field :start_time, :type => Integer
    field :end_time, :type => Integer
    field :timestamp, :type => Integer
    field :measurement_count, :type => Integer, :default => 0
    field :sum, :type => Integer, :default => 0
    field :sample_index, :type => Integer

    def initialize(attr = nil, options = nil, measurement = nil, index = 0)
      @seed_measurement = measurement
      @latest_measurement = nil
      super(attr, options)
      self.sample_index = index
      if stats.empty?
        self.stats = self.class.stats_defined.map(&:create_stat)
      end
    end

    def method_missing(method, *args)
      self.class.send(:define_method, method.to_sym) { get_stat_by_name(method) }
      get_stat_by_name(method)
    end

    def calculate(measurement)
      set_start_time(measurement) unless start_time
      @latest_measurement = measurement
      update_time(measurement)
      update_stats(measurement)
    end

    def complete
      return false if measurement_count < 1
      self.stats.each do |statistic|
        statistic.complete
      end
    end

    def duration_in_seconds
      return end_time - start_time if end_time && start_time
      return 0
    end

    def duration_from_previous_sample_in_seconds
      return duration_in_seconds unless seed_measurement
      end_time - seed_measurement.timestamp
    end

    def get_stat_by_name(name_of_stat)
      stats_by_name[name_of_stat] || raw_stat
    end

    def stats_by_name
      @stats_by_name ||= generate_stats_by_name
    end

    def is_summary?
      !interval
    end

    private

    def set_start_time(measurement)
      self.start_time = measurement.timestamp
      self.save! if is_summary?
    end

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
      self.end_time = measurement.timestamp
      self.timestamp = (self.sum / self.measurement_count).to_i
    end

    def update_stats(measurement)
      self.stats.each do |stat|
        stat.calculate(measurement)
      end
    end

    def new_sample
      self.class.new({:samplable => self.samplable, :interval => interval}, {}, @latest_measurement, sample_index + 1)
    end

    def self.stats_defined
      @stats_defined ||= []
    end

    def self.custom_stats_defined
      @custom_stats_defined ||= []
    end

    def self.axises_defined
      @axises_defined ||= []
    end

    def self.stat(property, stats_to_define = [:min, :mean, :max, :eightieth, :ninety_eighth], options = {})
      stats_to_define.each do |stat|
        klass = Stat.class_for(stat)
        access_name = klass.access_name(property)
        self.stats_defined << StatDefinition.new(property, klass, access_name, options)
      end
    end

    def self.custom_stat(name_of_stat, value_type, default = nil, axis = -1, &block)
      custom_stat_klass = Stat.create_custom_stat(name_of_stat,
                                                  value_type,
                                                  default,
                                                  block)
      access_name = custom_stat_klass.access_name
      options = {axis: axis}
      self.stats_defined << StatDefinition.new(name_of_stat, custom_stat_klass, access_name, options)
    end

    def self.axis(options)
      axises_defined << options
    end

    def raw_stat
      Stat.new(:value)
    end
  end
end