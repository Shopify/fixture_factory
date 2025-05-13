# frozen_string_literal: true

require "test_helper"

module FixtureFactory
  class SequenceUsageTest < FixtureFactory::TestCase
    include FixtureFactory::Methods
    include FixtureFactory::Registry

    define_factories do
      factory(:user) do |count|
        { email: "user-#{count}@example.com" }
      end

      factory(:locked_user, parent: :user) do
        { locked: true }
      end

      factory(:bob, parent: :user) do
        { name: "Bob" }
      end
    end

    test "attributes_for" do
      assert_match(/user-\d+@example.com/, attributes_for(:user)[:email])
      assert_not_equal attributes_for(:user)[:email], attributes_for(:user)[:email]
    end

    test "attributes_for_list" do
      attributes_for_list(:user, 2).each do |attributes|
        assert_match(/user-\d+@example.com/, attributes[:email])
      end
      assert_not_equal(*attributes_for_list(:user, 2))
      assert_not_equal attributes_for_list(:user, 2), attributes_for_list(:user, 2)
    end

    test "build" do
      assert_match(/user-\d+@example.com/, build(:user).email)
      assert_not_equal build(:user).email, build(:user).email
    end

    test "build_list" do
      build_list(:user, 2).each do |user|
        assert_match(/user-\d+@example.com/, user.email)
      end
      assert_not_equal(*build_list(:user, 2).map(&:email))
      assert_not_equal build_list(:user, 2).map(&:email), build_list(:user, 2).map(&:email)
    end

    test "create" do
      assert_match(/user-\d+@example.com/, create(:user).email)
      assert_not_equal create(:user).email, create(:user).email
    end

    test "create_list" do
      create_list(:user, 2).each do |user|
        assert_match(/user-\d+@example.com/, user.email)
      end
      assert_not_equal(*create_list(:user, 2).map(&:email))
      assert_not_equal create_list(:user, 2).map(&:email), create_list(:user, 2).map(&:email)
    end

    test "uniqueness preserved with parent" do
      assert_not_equal(create(:bob).email, create(:locked_user).email)
    end
  end
end
