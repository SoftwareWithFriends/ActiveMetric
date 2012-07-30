# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require 'minitest/reporters'
MiniTest::Unit.runner = MiniTest::SuiteRunner.new
if ENV["RM_INFO"] || ENV["TEAMCITY_VERSION"]
  MiniTest::Unit.runner.reporters << MiniTest::Reporters::RubyMineReporter.new
else
  MiniTest::Unit.runner.reporters << MiniTest::Reporters::ProgressReporter.new
end

module ActiveMetric
  INTERVAL_LENGTH = 5

  class TestMeasurement < Measurement
    field :value, :type => Integer, :default => 0
  end

  class TestStat < Stat
  end

  class TestSample < Sample
    stat :value
    stat :value, [:standard_deviation], axis: 1
    custom_stat :test_count, Integer, 0, 1 do |measurement|
      self.value += 1
    end
    custom_stat :test_response_codes, Hash, {} do |measurement|
      self.value[measurement.value.to_s] ||= 0
      self.value[measurement.value.to_s] += 1
    end

    axis index: 0, label: "first axis"
    axis index: 1, label: "second axis"
  end

  class TestSubject < Subject
    field :test_field
    calculated_with TestSample, INTERVAL_LENGTH
  end

end

class ActiveSupport::TestCase

  setup :clear_database
  def clear_database
    Mongoid.default_session.collections.select { |c| c.name != 'system.indexes' }.each(&:drop)
  end

  def assert_within_range(range, value)
    assert range === value, "Expected #{value} to be within #{range}"
  end

  def assert_close_to expected, actual
    rounded = ((actual * 100).round) / 100.0
    assert_equal expected, rounded
  end

end
