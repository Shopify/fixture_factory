# frozen_string_literal: true

module FixtureFactory
  class Seed # :nodoc:
    EMPTY_BLOCK = proc {}

    attr_accessor :block

    def initialize(name, options = {})
      @block = options.fetch(:block) { EMPTY_BLOCK }
    end
  end
end
