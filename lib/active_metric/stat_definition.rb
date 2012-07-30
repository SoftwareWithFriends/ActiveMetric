module ActiveMetric
  class StatDefinition

    attr_reader :name_of_stat, :klass, :access_name, :options

    def initialize(name_of_stat, klass, access_name, options)
      @name_of_stat, @klass, @access_name, @options = name_of_stat, klass, access_name, options
      @options[:axis] ||= 0
    end

    def create_stat
      klass.new(name_of_stat)
    end

    def graphable?
      options[:axis] >= 0
    end

  end
end