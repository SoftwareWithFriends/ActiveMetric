require_relative 'test_helper'

class MongoidTest < ActiveSupport::TestCase


  test "inherited documents from class dot new dont get a type" do
    class TopLevel
      include Mongoid::Document
    end

    class SecondLevel < TopLevel
    end

    second_level = SecondLevel.create
    assert_equal "MongoidTest::SecondLevel", second_level._type

    klass = Class.new(TopLevel)
    MongoidTest.const_set(:NewKlass, klass)

    new_object = NewKlass.create
    assert_equal "MongoidTest::NewKlass", new_object._type
    #assert_equal nil, new_object._type, "Mongoid correctly sets _type on Anonymous Classes now. Go remove the hack in stat: create_custom_stat WRT _type  "
  end
end
