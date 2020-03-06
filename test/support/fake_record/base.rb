# frozen_string_literal: true

module FakeRecord
  class Base
    include ActiveModel::Model

    def self.attributes(*names)
      define_method(:attributes) do
        names.map do |name|
          [name, send(name)]
        end.to_h
      end
      attr_accessor(*names)
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

    def self.create(attributes)
      new(attributes).tap(&:save!)
    end
  end
end
