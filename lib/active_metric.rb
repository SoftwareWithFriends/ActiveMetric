require 'mongoid'
require 'active_support/test_case'

require 'active_metric/behavior/graph_calculation'
require 'active_metric/behavior/calculates_derivative'
require 'active_metric/calculators/standard_deviator'

require 'active_metric/subject'
require 'active_metric/measurement'
require 'active_metric/sample'
require 'active_metric/stat'
require 'active_metric/statistics/defaults'
require 'active_metric/statistics/standard_deviation'
require 'active_metric/report'
require 'active_metric/calculators/reservoir'
require 'active_metric/report_view_model'
require 'active_metric/graph_view_model'
require 'active_metric/series_data'
require 'active_metric/point_series_data'
require 'active_metric/axis'
require 'active_metric/stat_definition'

module ActiveMetric
  CONFIG_PATH = File.join(File.dirname(__FILE__),"active_metric/config")

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.logger=(new_logger)
    @logger = new_logger
  end

end

Dir.glob("#{File.dirname(__FILE__)}/active_metric/config/initializers/*").each do |initializer|
  require initializer
end
