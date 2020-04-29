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
      block = proc { factory(:recipe_fixtury, class_name: "Recipe") }
      registry.define_factories(&block)
      assert_nothing_raised do
        assert_instance_of FixtureFactory::Definition, registry.all_factory_definitions.fetch(:recipe_fixtury)
      end
    end

    test ".factory works with deprecated class: option" do
      assert_deprecated do
        registry.define_factories do
          factory(:recipe_fixtury, class: "Recipe")
          factory(:user_fixtury, class: User)
        end
      end
      assert_nothing_raised do
        assert_equal Recipe, registry.all_factory_definitions.fetch(:recipe_fixtury).klass
        assert_equal User, registry.all_factory_definitions.fetch(:user_fixtury).klass
      end
    end

    test ".all_factory_definitions returns inherited hash of fixture factories" do
      registry.define_factories do
        factory(:recipe, class_name: "Recipe")
      end
      child_registry.define_factories do
        factory(:recipe_with_instructions, class_name: "Recipe") do
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
        factory(:recipe, class_name: "Recipe", &parent_block)
      end
      child_registry.define_factories do
        factory(:recipe, class_name: "Recipe", &child_block)
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
