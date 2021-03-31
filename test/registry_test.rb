# frozen_string_literal: true

require "test_helper"

module FixtureFactory
  class RegistryTest < FixtureFactory::TestCase
    class TestRegistry
      include FixtureFactory::Registry
    end

    class ChildTestRegistry < TestRegistry
    end

    setup do
      @registry = TestRegistry
      @child_registry = ChildTestRegistry
    end

    teardown do
      registry.fixture_factory_definitions = nil
      child_registry.fixture_factory_definitions = nil
    end

    attr_reader :registry, :child_registry

    test ".factory defines fixture factories" do
      block = proc { factory(:recipe_fixtury, class: -> { Recipe }) }
      registry.define_factories(&block)
      assert_nothing_raised do
        assert_instance_of FixtureFactory::Definition, registry.all_factory_definitions.fetch(:recipe_fixtury)
      end
    end

    test ".factory works with class_name: option" do
      block = proc { factory(:recipe_fixtury, class_name: "Recipe") }
      registry.define_factories(&block)
      assert_nothing_raised do
        assert_equal Recipe, registry.all_factory_definitions.fetch(:recipe_fixtury).klass
      end
    end

    test ".factory raises correct message with class_name: option" do
      block = proc { factory(:recipe_fixtury, class_name: "NonExistingClass") }
      registry.define_factories(&block)

      error = assert_raises(WrongClassError) do
        registry.all_factory_definitions.fetch(:recipe_fixtury).klass
      end
      assert_equal <<~MSG.squish, error.message
        No class named "NonExistingClass".
        Try using the `class_name` option in your definition to specify a valid class name.
        https://github.com/Shopify/fixture_factory/blob/master/README.md#naming
      MSG
    end

    test ".all_factory_definitions returns inherited hash of fixturies" do
      registry.define_factories do
        factory(:recipe, class: -> { Recipe })
      end
      child_registry.define_factories do
        factory(:recipe_with_instructions, class: -> { Recipe }) do
          { instructions: 'Step 1...' }
        end
      end
      assert_equal %w(recipe), registry.all_factory_definitions.keys
      assert_equal %w(recipe recipe_with_instructions), child_registry.all_factory_definitions.keys
    end

    test ".all_factory_definitions returns subclass definitions first" do
      child_registry = ChildTestRegistry
      parent_block = proc { { name: 'Parent' } }
      child_block  = proc { { name: 'Child' } }
      registry.define_factories do
        factory(:recipe, class: -> { Recipe }, &parent_block)
      end
      child_registry.define_factories do
        factory(:recipe, class: -> { Recipe }, &child_block)
      end
      assert_equal 'Parent', FixtureFactory.build(:recipe, scope: registry).name
      assert_equal 'Child', FixtureFactory.build(:recipe, scope: child_registry).name
    end

    test ".define_factories initializes fixtury_definitions accepts a contextual block" do
      test_case = self
      assert_nil registry.fixture_factory_definitions
      registry.define_factories do
        test_case.assert_equal(test_case.registry, self)
      end
      assert_equal({}.with_indifferent_access, registry.fixture_factory_definitions)
    end

    test ".define_factories does not clear existing factory definitions" do
      assert_nil registry.fixture_factory_definitions
      registry.define_factories do
        factory(:user)
      end

      registry.define_factories do
        factory(:team)
      end

      assert_equal(["user", "team"], registry.fixture_factory_definitions.keys)
    end

    test ".fixture_factory_definitions do not contain parent definitions" do
      child_registry = ChildTestRegistry
      registry.define_factories do
        factory(:book)
      end
      child_registry.define_factories do
        factory(:recipe)
      end
      assert_equal child_registry.fixture_factory_definitions.keys, ["recipe"]
    end
  end
end
