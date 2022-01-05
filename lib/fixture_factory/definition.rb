# frozen_string_literal: true

module FixtureFactory
  class Definition # :nodoc:
    EMPTY_BLOCK = proc {}

    attr_writer   :block
    attr_accessor :fixture_method, :fixture_name, :parent, :sequence, :proc_class

    def initialize(name, options = {})
      self.parent         = options.fetch(:parent) { default_parent_for(name) }
      self.proc_class     = options.fetch(:class)  { parent.proc_class }
      self.fixture_method = options.fetch(:via)    { parent.fixture_method }
      self.fixture_name   = options.fetch(:like)   { parent.fixture_name }
      self.block          = options.fetch(:block)  { EMPTY_BLOCK }
      self.sequence       = Sequence.new
    end

    def block
      all_blocks = [parent&.block, @block].compact
      ->(*args) do
        all_blocks.reduce({}) do |attributes, block|
          block_attributes = FixtureFactory.evaluate(
            block, args: args, context: self
          )
          attributes.merge(block_attributes)
        end
      end
    end

    def klass
      @klass ||= proc_class.call
    rescue NameError
      raise WrongClassError, proc_class
    end

    def fixture_args
      [fixture_method, fixture_name]
    end

    def from_fixture?
      fixture_name.present? && fixture_method.present?
    end

    def run(context:)
      FixtureFactory.evaluate(runner, context: context)
    end

    private

    def runner
      definition = self
      args = sequence.take(1)
      -> do
        attributes = FixtureFactory.evaluate(definition.block, args: args, context: self)
        if definition.from_fixture?
          begin
            fixture = send(*definition.fixture_args)
            attributes.reverse_merge!(fixture.attributes)
          rescue NoMethodError
            raise WrongFixtureMethodError, definition.fixture_args.first
          end
        end
        attributes
      end
    end

    def default_parent_for(name)
      self.class.new(
        name,
        parent: nil,
        like: nil,
        class: -> { name.to_s.classify.safe_constantize },
        via: name.to_s.pluralize,
      )
    end
  end
end
