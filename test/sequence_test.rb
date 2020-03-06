# frozen_string_literal: true

require "test_helper"

module FixtureFactory
  class SequenceTest < FixtureFactory::TestCase
    setup do
      @tested_class = FixtureFactory::Sequence
      @subject = tested_class.new
    end

    attr_reader :tested_class, :subject

    test "is Enumberable" do
      assert_includes tested_class.included_modules, Enumerable
    end

    test "#next increments value" do
      assert_equal (1..3).to_a, 3.times.map { subject.next }
    end

    test "#each increments value" do
      assert_equal (1..10).to_a, subject.take(10)
    end
  end
end
