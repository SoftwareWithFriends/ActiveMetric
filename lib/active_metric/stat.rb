module ActiveMetric
  class CannotInstantiateBaseStat < Exception;
  end

  class Stat
    include Mongoid::Document

    embedded_in :calculable, :polymorphic => true
    field :value, :type => Float, :default => 0
    field :property, :type => String
    field :axis, :type => Integer, :default => 0

    def initialize(property, *args)
      super(*args)
      self.property = property
    end

    def access_name
      self.class.access_name(property)
    end

    def calculate(measurement)
      raise CannotInstantiateBaseStat
    end

    def complete
    end

    def self.class_for(stat)
      eval(stat.to_s.classify)
    end

    def self.access_name(property = nil)
      title = name.split("::").last.underscore
      title += "_#{property}" if property
      title.to_sym
    end

    #TODO FIGURE OUT A WAY TO MAKE CUSTOM CLASSES NOT NEED TO BE INSIDE OF ACTIVE METRIC (I.E. LET THEM BE NAMESPACED)
    def self.create_custom_stat(name_of_stat, value_type, default, calculate_block)
      class_name = name_of_stat.to_s.camelcase
      if ActiveMetric.const_defined?(class_name)
        ActiveMetric.logger.warn "\n\n#{class_name} is already defined. It won't be defined again.\n\n"
        return ActiveMetric.const_get(class_name)
      end
      klass = Class.new(Custom) do
        define_method(:calculate, calculate_block)
      end
      klass.send(:field, :_type, :default => "ActiveMetric::#{class_name}")
      klass.send(:field, :value, :type => value_type, :default => default)
      ActiveMetric.const_set(class_name, klass)
      return klass
    end

    def subject
      self.calculable.samplable
    end

    def property_from(measurement)
      return nil unless measurement
      measurement.send(self.property)
    end

  end

  class Custom < Stat

    def access_name
      self.class.access_name
    end

  end
end