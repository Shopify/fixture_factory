# frozen_string_literal: true

require "test_helper"

module FixtureFactory
  class MethodsTest < FixtureFactory::TestCase
    include FixtureFactory::Methods
    include FixtureFactory::Registry

    define_factories do
      factory(:user, class: -> { User }) do
        user_factory_attributes
      end

      factory(:address, class: -> { Address }) do
        address_factory_attributes
      end

      factory(:account, class: -> { Account }) do
        account_factory_attributes
      end
    end

    test "#attributes_for returns attributes of a model" do
      assert_equal user_factory_attributes, attributes_for(:user)
    end

    test "#attributes_for with overrides returns attributes of a model with overrides" do
      assert_equal user_factory_attributes.merge(locked: true), attributes_for(:user, locked: true)
    end

    test "#attributes_for_list returns a list of attributes of a model" do
      count = 5
      user_factory_attributes_list = count.times.map { user_factory_attributes }
      assert_equal user_factory_attributes_list, attributes_for_list(:user, count)
    end

    test "#attributes_for_list with overrides returns a list of attributes of a model with overrides" do
      count = 5
      user_factory_attributes_list = count.times.map { user_factory_attributes.merge(settings: {}) }
      assert_equal user_factory_attributes_list, attributes_for_list(:user, count, settings: {})
    end

    test "#build returns attributes of a model" do
      account = Account.new(account_factory_attributes)
      assert_attributes account, build(:account)
    end

    test "#build with overrides returns attributes of a model with overrides" do
      account = Account.new(account_factory_attributes.merge(user_id: 99))
      assert_attributes account, build(:account, user_id: 99)
    end

    test "#build_list returns a list of attributes of a model" do
      count = 5
      account_list = count.times.map { Account.new(account_factory_attributes) }
      assert_attributes account_list, build_list(:account, count)
    end

    test "#build_list with overrides returns a list of attributes of a model with overrides" do
      count = 5
      account_list = count.times.map do
        Account.new(account_factory_attributes.merge(company: 'Apple Inc.'))
      end
      assert_attributes account_list, build_list(:account, count, company: 'Apple Inc.')
    end

    test "#create returns attributes of a model" do
      address = Address.create(address_factory_attributes)
      assert_attributes address, create(:address)
    end

    test "#create with overrides returns attributes of a model with overrides" do
      address = Address.create(address_factory_attributes.merge(name: nil, primary: false))
      assert_attributes address, create(:address, name: nil, primary: false)
    end

    test "#create_list returns a list of attributes of a model" do
      count = 5
      address_list = count.times.map { Address.create(address_factory_attributes) }
      assert_attributes address_list, create_list(:address, count)
    end

    test "#create_list with overrides returns a list of attributes of a model with overrides" do
      count = 5
      address_list = count.times.map do
        Address.new(address_factory_attributes.merge(location: '150 Elgin St. Ottawa, ON'))
      end
      assert_attributes address_list, create_list(:address, count, location: '150 Elgin St. Ottawa, ON')
    end

    private

    def user_factory_attributes
      {
        email: "tester@example.com",
        name: %w(Tester T Testerson),
        locked: false,
        settings: { theme: 'Orange' },
      }
    end

    def address_factory_attributes
      {
        name: 'Home',
        location: '123 Fake St. Winnipeg, MB',
        primary: true,
      }
    end

    def account_factory_attributes
      {
        plan: :startup,
        company: 'Shopify Inc.',
        user: build(:user),
      }
    end
  end
end
