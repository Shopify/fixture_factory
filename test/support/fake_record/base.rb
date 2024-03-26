# frozen_string_literal: true

module FakeRecord
  class Base
    include ActiveModel::Model

    class << self
      def attributes(*names)
        define_method(:attributes) do
          names.map do |name|
            [name, send(name)]
          end.to_h
        end
        attr_accessor(*names)
      end

      def create(attributes)
        new(attributes).tap(&:save!)
      end
    end

    def ==(other)
      attributes == other.attributes
    end

    def save!
      @persisted = true
    end

    def persisted?
      @persisted
    end
  end
end
