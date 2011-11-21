# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

module ActiveMetric
  INTERVAL_LENGTH = 5

  class TestMeasurement < Measurement
    field :value, :type => Integer, :default => 0
  end

  class TestStat < Stat
  end

  class TestSample < Sample
    #stat :value
    stat :value, [:estimated_eightieth, :eightieth]
    custom_stat :test_count, Integer, 0 do |measurement|
      self.value += 1
    end
    custom_stat :test_response_codes, Hash, {} do |measurement|
      self.value[measurement.value.to_s] ||= 0
      self.value[measurement.value.to_s] += 1
    end
  end

  class TestSubject < Subject
    calculated_with TestSample, INTERVAL_LENGTH
  end

end

class ActiveSupport::TestCase

    def assert_within_range(range, value)
      assert range === value, "Expected #{value} to be within #{range}"
    end

end
