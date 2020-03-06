# frozen_string_literal: true

module FixtureFactory
  class Error < StandardError # :nodoc:
  end

  # Raised when a factory is referenced, but not defined.
  class NotFoundError < Error
    def initialize(fixture_name)
      super(
        <<~MSG.squish
          No factory named "#{fixture_name}".
          Did you forget to define it?
          https://github.com/Shopify/fixture_factory/blob/master/README.md#definition
        MSG
      )
    end
  end

  class WrongFixtureMethodError < Error
    def initialize(method_name)
      super(
        <<~MSG.squish
          No fixture method named "#{method_name}".
          Try using the `via` option in your definition to specify a valid method.
          https://github.com/Shopify/fixture_factory/blob/master/README.md#naming
        MSG
      )
    end
  end

  class WrongClassError < Error
    def initialize(class_name)
      super(
        <<~MSG.squish
          No class named "#{class_name}".
          Try using the `class` option in your definition to specify a valid class name.
          https://github.com/Shopify/fixture_factory/blob/master/README.md#naming
        MSG
      )
    end
  end
end
