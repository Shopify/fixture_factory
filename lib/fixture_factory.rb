# frozen_string_literal: true

require "fixture_factory/version"
require "fixture_factory/definition"
require "fixture_factory/methods"
require "fixture_factory/registry"
require "fixture_factory/sequence"
require "fixture_factory/errors"

module FixtureFactory
  class << self
    def attributes_for(name, **options) # :nodoc:
      _, attributes = retrieve(name, **options)
      attributes
    end

    def build(name, **options) # :nodoc:
      klass, attributes = retrieve(name, **options)
      klass.new(attributes)
    end

    def create(name, **options) # :nodoc:
      build(name, **options).tap(&:save!)
    end

    def evaluate(block, args: [], context:) # :nodoc:
      attributes = context.instance_exec(*args, &block)
      extract_attributes(attributes)
    end

    private

    def extract_attributes(object)
      raise ArgumentError, "FixtureFactory blocks must return a hash-like object" unless object.respond_to?(:to_h)
      object.to_h.symbolize_keys
    end

    def retrieve(name, scope:, context: nil, overrides: {})
      definition = scope.all_factory_definitions.fetch(name) do
        raise NotFoundError, name
      end
      attributes = definition.run(context: context)
      attributes.merge!(overrides).delete(:id)
      [definition.klass, attributes]
    end
  end
end
