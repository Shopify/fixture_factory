# frozen_string_literal: true

module FixtureFactory
  module Methods
    # Generates a hash of attributes given a factory name and an optional
    # hash of override attributes.
    #
    # === Example
    #
    # attributes_for(:user)
    # attributes_for(:blog, title: 'Riding Rails')
    # attributes_for(:comment, content: 'Hello', approved: false)
    # attributes_for(:post, comments_attributes: [attributes_for(:comment)])
    def attributes_for(name, overrides = {})
      FixtureFactory.attributes_for(
        name, overrides: overrides, context: self, scope: self.class
      )
    end

    # Generates an array of hash attributes given a factory name, a count,
    # and an optional hash of override attributes.
    #
    # === Example
    #
    # attributes_for_list(:user, 5)
    # attributes_for_list(:blog, 3, title: 'Riding Rails')
    # attributes_for_list(:comment, 50, content: 'Hello', approved: false)
    # attributes_for_list(:post, 3, comments_attributes: attributes_for_list(:comment, 1))
    def attributes_for_list(name, count, overrides = {})
      count.times.map { attributes_for(name, overrides) }
    end

    # Generates an instance of a model given a factory name and an optional
    # hash of override attributes.
    #
    # === Example
    #
    # build(:user)
    # build(:blog, title: 'Riding Rails')
    # build(:comment, content: 'Hello', approved: false)
    # build(:post, comments: [build(:comment)])
    def build(name, overrides = {})
      FixtureFactory.build(
        name, overrides: overrides, context: self, scope: self.class
      )
    end

    # Generates an array of model instances given a factory name and an optional
    # hash of override attributes.
    #
    # === Example
    #
    # build_list(:user, 5)
    # build_list(:blog, 3, title: 'Riding Rails')
    # build_list(:comment, 50, content: 'Hello', approved: false)
    # build_list(:post, 3, comments: build_list(:comment, 1))
    def build_list(name, count, overrides = {})
      count.times.map { build(name, overrides) }
    end

    # Generates a persisted model instance given a factory name and an optional
    # hash of override attributes.
    #
    # === Example
    #
    # create(:user)
    # create(:blog, title: 'Riding Rails')
    # create(:comment, content: 'Hello', approved: false)
    # create(:post, comments: [create(:comment)])
    def create(name, overrides = {})
      FixtureFactory.create(
        name, overrides: overrides, context: self, scope: self.class
      )
    end

    # Generates an array of persisted model instances given a factory name and
    # an optional hash of override attributes.
    #
    # === Example
    #
    # create_list(:user, 5)
    # create_list(:blog, 3, title: 'Riding Rails')
    # create_list(:comment, 50, content: 'Hello', approved: false)
    # create_list(:post, 3, comments: create_list(:comment, 1))
    def create_list(name, count, overrides = {})
      count.times.map { create(name, overrides) }
    end
  end
end
