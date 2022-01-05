# frozen_string_literal: true

require "test_helper"

module FixtureFactory
  class DefinitionTest < FixtureFactory::TestCase
    setup do
      @tested_class = FixtureFactory::Definition
      @empty_block  = tested_class::EMPTY_BLOCK
    end

    attr_reader :tested_class, :empty_block

    test "#initialize derives from default parent defaults" do
      subject = tested_class.new(:string)
      assert_instance_of tested_class, subject.parent
      assert_equal String, subject.klass
      assert_equal "strings", subject.fixture_method
      assert_nil subject.fixture_name
      assert_same empty_block, subject.instance_variable_get(:@block)
    end

    test "#initialize allows explicit parent" do
      parent  = tested_class.new(:parent_fixtury, class: -> { Object }, via: :parent_method, like: :parent_name)
      subject = tested_class.new(:child_fixtury, parent: parent)
      assert_same parent, subject.parent
      assert_equal parent.klass, subject.klass
      assert_equal parent.fixture_method, subject.fixture_method
      assert_equal parent.fixture_name, subject.fixture_name
    end

    test "#initialize allows explicit class" do
      subject = tested_class.new(:child_fixtury, class: -> { String })
      assert_equal String, subject.klass
    end

    test "#initialize allows explicit fixture_method" do
      subject = tested_class.new(:child_fixtury, via: :some_method)
      assert_equal :some_method, subject.fixture_method
    end

    test "#initialize allows explicit fixture_name" do
      subject = tested_class.new(:child_fixtury, like: :some_name)
      assert_equal :some_name, subject.fixture_name
    end

    test "#initialize allows explicit block" do
      block = proc {}
      subject = tested_class.new(:child_fixtury, block: block)
      assert_same block, subject.instance_variable_get(:@block)
    end

    test "#block wraps block ivar and parent block in a hash merge reducer" do
      parent_block = proc { { foo: :bar, fizz: :buzz } }
      child_block  = proc { { foo: :baz, great: :scott } }
      subject = tested_class.new(:fixture, block: child_block)
      subject.parent.block = parent_block
      assert_equal({ foo: :baz, fizz: :buzz, great: :scott }, subject.block.call)
    end

    test "#block wraps all blocks in provided context" do
      parent_block = proc { parent_attributes }
      child_block  = proc { child_attributes }
      subject = tested_class.new(:fixture, block: child_block)
      subject.parent.block = parent_block
      assert_equal({ parent: true, child: true }, FixtureFactory.evaluate(subject.block, context: self))
    end

    test "#klass= assigns classes normally" do
      subject = tested_class.new(:fixture)
      subject.proc_class = -> { Object }
      assert_equal Object, subject.klass
    end

    test "#klass raises WrongClassError when class is invalid" do
      subject = tested_class.new(:fixture)
      subject.proc_class = -> { TheClassIsALie }
      error = assert_raises(WrongClassError) do
        subject.klass
      end
      assert_equal <<~MSG.squish, error.message
        Constant defined in file #{__FILE__} on line 77 is not defined.
        Try using the `class` option in your definition to specify a valid class name.
        https://github.com/Shopify/fixture_factory/blob/master/README.md#naming
      MSG
    end

    test "#fixture_args returns fixture arguments" do
      subject = tested_class.new(:fixture, via: :users, like: :bob)
      assert_equal [:users, :bob], subject.fixture_args
    end

    test "#from_fixture? returns true when fixture attributes present" do
      subject = tested_class.new(:fixture)
      refute_predicate subject, :from_fixture?
    end

    test "#from_fixture? returns false when fixture attributes blank" do
      subject = tested_class.new(:fixture, via: :meth, like: :name)
      assert_predicate subject, :from_fixture?
    end

    test "#run evaluates fixtureless fixture in a given context" do
      block = proc { child_attributes }
      subject = tested_class.new(:user, block: block)
      assert_equal({ child: true }, subject.run(context: self))
    end

    test "#run evaluates fixture fixture in a given context" do
      block = proc { child_attributes }
      subject = tested_class.new(:user, like: :bob, block: block)
      assert_equal({ child: true, name: "Bob" }, subject.run(context: self).slice(:child, :name))
    end

    test "#run raises WrongFixtureMethodError when fixture method is invalid" do
      subject = tested_class.new(:user, via: :cool_users, like: :bob)
      error = assert_raises(WrongFixtureMethodError) do
        subject.run(context: self)
      end
      assert_equal <<~MSG.squish, error.message
        No fixture method named "cool_users".
        Try using the `via` option in your definition to specify a valid method.
        https://github.com/Shopify/fixture_factory/blob/master/README.md#naming
      MSG
    end

    private

    def parent_attributes
      { parent: true, child: false }
    end

    def child_attributes
      { child: true }
    end
  end
end
