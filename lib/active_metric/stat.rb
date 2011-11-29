module ActiveMetric
  class CannotInstantiateBaseStat < Exception; end

  class Stat
    include Mongoid::Document

    embedded_in :calculable, :polymorphic => true
    field :value, :type => Float, :default => 0
    field :property, :type => String

    def initialize(property,*args)
      self.property = property
      super(*args)
    end

    def access_name
      title = self.class.name.split("::").last.underscore
      title += "_#{self.property}" unless self.kind_of? Custom
      title.to_sym
    end

    def axis
      0
    end

    def calculate(measurement)
      raise CannotInstantiateBaseStat
    end

    def complete
    end

    def self.class_for(stat)
      eval(stat.to_s.classify)
    end

    #TODO FIGURE OUT A WAY TO MAKE CUSTOM CLASSES NOT NEED TO BE INSIDE OF ACTIVE METRIC (I.E. LET THEM BE NAMESPACED)
    def self.create_custom_stat(name_of_stat, value_type, default, axis, calculate_block)
      class_name = name_of_stat.to_s.camelcase
      if ActiveMetric.const_defined?(class_name)
        Rails.logger.warn "\n\n#{class_name} is already defined. It won't be defined again.\n\n"
        return ActiveMetric.const_get(class_name)
      end
      klass = Class.new(Custom) do
        define_method(:calculate,calculate_block)
        define_method(:axis) do
          axis
        end
      end
      klass.send(:field, :value, :type => value_type, :default => default)
      ActiveMetric.const_set(class_name,klass)
      return klass

    end

    def subject
      self.calculable.samplable
    end
  end

  class Custom < Stat

  end
end