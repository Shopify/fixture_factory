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

    test ".fixture defines fixturies" do
      block = proc { fixture(:recipe_fixtury, class: Recipe) }
      registry.define_factories(&block)
      assert_nothing_raised do
        assert_instance_of FixtureFactory::Definition, registry.all_factory_definitions.fetch(:recipe_fixtury)
      end
    end

    test ".all_factory_definitions returns inherited hash of fixturies" do
      registry.define_factories do
        fixture(:recipe, class: Recipe)
      end
      child_registry.define_factories do
        fixture(:recipe_with_instructions, class: Recipe) do
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
        fixture(:recipe, class: Recipe, &parent_block)
      end
      child_registry.define_factories do
        fixture(:recipe, class: Recipe, &child_block)
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
  end
end
