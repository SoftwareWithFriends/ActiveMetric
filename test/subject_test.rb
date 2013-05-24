require_relative 'test_helper'

module ActiveMetric

  class SubjectTest < ActiveSupport::TestCase


    test "can retrieve report specific fields" do

      class SubjectWithFields < Subject
        field :foo

        calculated_with Sample, 5
      end

      expected_fields = {foo: "bar"}.stringify_keys

      subject = SubjectWithFields.create foo: "bar"
      assert_equal expected_fields, subject.not_inherited_attributes
    end
  end
end
