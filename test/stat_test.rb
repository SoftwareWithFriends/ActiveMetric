require 'test_helper'

module ActiveMetric
  class StatTest < ActiveSupport::TestCase

    setup do
      @subject = TestSubject.create
      @sample = TestSample.create(:samplable => @subject)
      @stat = TestStat.new :property, :calculable => @sample
    end

    test "create a new stat" do
      assert @stat
    end

    test "stat is a mongoid document" do
      assert @stat.kind_of?(Mongoid::Document)
    end

    test "calculate raises an error if not implemented" do
      assert_raise CannotInstantiateBaseStat do
        @stat.calculate(mock)
      end
    end

    test "has a dynamically defined name" do
      assert_equal :test_stat_property, @stat.access_name
    end

    test "sets name for custom stat" do
      proc = Proc.new {|m|self.value = m.value}
      stat = Stat.create_custom_stat(:property,Integer,{},0,proc).new(:property)
      assert_equal :property, stat.access_name
    end

    test "custom stat uses block to calculate" do
      proc = Proc.new {|m| self.value = m.value}
      stat = Stat.create_custom_stat(:property,Integer,{},0, proc).new(:property)
      measurement = mock(:value => 10)
      stat.calculate(measurement)
      assert_equal 10, stat.value
    end

    test "can calculate min" do
      stat = Min.new(:value, :calculable => @sample)
      test_stat(stat,10.times)
      assert_equal 0, stat.value
    end

    test "can calculate max" do
      stat = Max.new(:value, :calculable => @sample)
      test_stat(stat, 10.times)
      assert_equal 9, stat.value
    end

    test "can calculate mean" do
      stat = Mean.new(:value, :calculable => @sample)
      test_stat(stat, 10.times)
      assert_equal 4.5, stat.value
    end

    #this test is here for the user, not for automated tests
    #test "random distributions are good too" do
    #  stat = StandardDeviation.new(:value, :calculable => @sample)
    #  100.times do
    #    stat.calculate TestMeasurement.create(:value => rand(100))
    #  end
    #  stat.complete
    #  assert_close_to 28.87, stat.value
    #end

    test "has subject" do
      subject = TestSubject.create
      sample = TestSample.create(:samplable => subject)
      assert_equal subject, sample.stats.first.subject
    end

    private

    def test_stat(stat, values)
      values.each  do |value|
        stat.calculate TestMeasurement.new(:value => value)
      end
      stat.complete
    end




  end
end