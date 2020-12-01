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
    def initialize(klass)
      message = if klass.is_a?(String)
        string_class_error_message(klass)
      else
        proc_class_error_message(klass)
      end
      super(message)
    end

    private

    def proc_class_error_message(proc_class)
      location, line_number = proc_class.source_location
      <<~MSG.squish
        Constant defined in file #{location} on line #{line_number} is not defined.
        Try using the `class` option in your definition to specify a valid class name.
        https://github.com/Shopify/fixture_factory/blob/master/README.md#naming
      MSG
    end

    def string_class_error_message(class_name)
      <<~MSG.squish
        No class named "#{class_name}".
        Try using the `class_name` option in your definition to specify a valid class name.
        https://github.com/Shopify/fixture_factory/blob/master/README.md#naming
      MSG
    end
  end
end
