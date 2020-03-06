# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))

require "active_support"
require "active_model"
require "active_record"
require "fixture_factory"

require "support/schema"
require "support/fake_record/base"

require "models/account"
require "models/address"
require "models/user"
require "models/recipe"
require "models/post"

require "active_support/testing/autorun"

module FixtureFactory
  class TestCase < ActiveSupport::TestCase
    include ActiveRecord::TestFixtures

    GEM_ROOT = File.expand_path("..", __dir__)

    self.fixture_path = File.join(GEM_ROOT, "test", "fixtures")

    fixtures :all

    def assert_attributes(expected_models, models)
      expected_attributes = Array(expected_models).map(&:attributes)
      attributes          = Array(models).map(&:attributes)
      assert_equal(expected_attributes, attributes)
    end
  end
end
