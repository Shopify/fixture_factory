# frozen_string_literal: true

module FixtureFactory
  class Sequence # :nodoc:
    include Enumerable

    def initialize
      @count = 0
    end

    def next
      @count += 1
    end

    def each
      loop { yield(self.next) }
    end
  end
end
