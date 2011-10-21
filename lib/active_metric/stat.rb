module ActiveMetric
  class CannotInstantiateBaseStat < Exception; end

  class Stat
    include Mongoid::Document

    embedded_in :calculable, :polymorphic => true
    field :value, :type => Float, :default => 0
    field :thing_to_measure, :type => String

    def initialize(thing_to_measure, *args)
      super(*args)
      self.thing_to_measure = thing_to_measure
    end

    def access_name
      title = self.class.name.split("::").last.underscore
      title += "_#{self.thing_to_measure}" unless self.kind_of? Custom
      title.to_sym
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
    def self.create_custom_stat(name_of_stat, value_type, default, calculate_block)
      class_name = name_of_stat.to_s.camelcase
      if ActiveMetric.const_defined?(class_name)
        Rails.logger.warn "\n\n#{class_name} is already defined. Not redefining it.\n\n"
        return ActiveMetric.const_get(class_name)
      end
      klass = Class.new(Custom) do
        define_method(:calculate,calculate_block)
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

  class Min < Stat
    field :value, :type => Float, :default => 1073741823
    def calculate(measurement)
      self.value = [self.value, measurement.send(self.thing_to_measure)].min
    end
  end

  class Max < Stat
    def calculate(measurement)
      self.value = [self.value, measurement.send(self.thing_to_measure)].max
    end
  end

  class Mean < Stat
    field :sum, :type => Float, :default => 0.0
    field :count, :type => Integer, :default => 0

    def calculate(measurement)
      self.count +=  1
      self.sum   +=  measurement.send(self.thing_to_measure)
    end

    def complete
      self.value = (self.sum / self.count).to_f
      super
    end
  end

  class Eightieth < Stat
    field :measurement_class, :type => String
    def calculate(measurement)
      self.measurement_class ||= measurement.class.name
    end
    def complete
      measurement = eval(self.measurement_class.classify).eightieth(subject, self.thing_to_measure.to_sym).first if self.measurement_class
      self.value = measurement.send(self.thing_to_measure) if measurement
      super
    end
  end

  class NinetyEighth < Stat
    field :measurement_class, :type => String
    def calculate(measurement)
      self.measurement_class ||= measurement.class.name
    end
    def complete
      measurement =  eval(self.measurement_class.classify).ninety_eighth(subject, self.thing_to_measure.to_sym).first if self.measurement_class
      self.value = measurement.send(self.thing_to_measure) if measurement
      super
    end
  end

end