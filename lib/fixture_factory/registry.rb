# frozen_string_literal: true

require "active_support/core_ext/hash/indifferent_access"

module FixtureFactory
  module Registry
    extend ActiveSupport::Concern

    included do
      class_attribute(:fixture_factory_definitions) # :nodoc:
    end

    class_methods do
      # Defines a fixture given a name, options, and a block.
      #
      # === Options
      #
      # [:parent]
      #   Specify a parent fixture to inherit options from. If no parent is specified,
      #   a default parent will be assumed that guesses class a via options.
      # [:class]
      #   Specify a class (typically as a string to prevent autoloading) to instantiate
      #   when building or creating models from fixturies. This option is guessed
      #   using the classified fixture name.
      # [:via]
      #   Specify a fixture method to call when generating data. Only necessary when
      #   the `like` option is used to specify a fixture name. This option is guessed
      #   by default using the pluralized fixture name.
      # [:like]
      #   Specify a fixture to use when generating data. Used in combination with
      #   `via` to extract attributes from a fixture.
      # [:block]
      #   Specify a block to call when running a fixture. This option will default to
      #   a passed block or an empty block if neither are provided.
      #
      # === Example
      #
      # define_factories do
      #   factory(:user, like: :bob)
      #   factory(:active_user, parent: :user) do
      #     { active: true }
      #   end
      #   factory(:cool_user, class: 'User') do
      #     { status: :cool }
      #   end
      #   factory(:admin, via: :users, like: :bob_admin, class: 'User')
      # end
      def factory(name, options = {}, &block)
        if options.key?(:class_name)
          options[:class] ||= -> do
            class_name = options.delete(:class_name).to_s
            class_name.constantize
          rescue NameError
            raise WrongClassError, class_name
          end
        end

        parent = all_factory_definitions[options[:parent]]
        options[:parent] = parent if options.key?(:parent)
        options[:block]  = block if block
        fixture_factory_definitions[name] = Definition.new(name, options)
      end

      # Sets up factories definitions for the current class scope. Accepts an
      # optional block to define factories in.
      #
      # === Example
      #
      # class SomeTest < ActiveSupport::TestCase
      #   define_factories do
      #     factory(:blog)
      #   end
      # end
      #
      # SomeTest.define_factories do
      #   factory(:post)
      # end
      def define_factories(&block)
        self.fixture_factory_definitions = {}.with_indifferent_access
        instance_exec(&block) if block.present?
      end

      def all_factory_definitions # :nodoc:
        fixtury_ancestors = ancestors.select do |ancestor|
          ancestor.respond_to?(:fixture_factory_definitions)
        end
        [self, *fixtury_ancestors].map(&:fixture_factory_definitions).reduce(:reverse_merge)
      end
    end
  end
end
