require_relative 'test_helper'

class ActiveMetricTest < ActiveSupport::TestCase

  setup do
    ActiveMetric.logger = nil
  end

  teardown do
    ActiveMetric.logger = nil
  end

  test "can use logger" do

    Logger.any_instance.expects(:info).with("Test")

    ActiveMetric.logger.info "Test"
  end

  test "can set a logger" do
    mock_logger = mock

    ActiveMetric.logger = mock_logger

    mock_logger.expects(:info).with("Test")

    ActiveMetric.logger.info("Test")
  end

end
