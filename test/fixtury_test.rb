# frozen_string_literal: true

require "test_helper"

class FixturyTest < FixtureFactory::TestCase
  include FixtureFactory::Registry

  define_factories do
    factory(:post, class: -> { Post }) do
      post_factory_attributes
    end
  end

  test ".attributes_for returns attributes of a model" do
    assert_equal post_factory_attributes, FixtureFactory.attributes_for(
      :post, context: self, scope: self.class, overrides: {}
    )
  end

  test ".attributes_for with overrides returns attributes of a model" do
    override_attributes = post_factory_attributes.merge(active: false)
    assert_equal override_attributes, FixtureFactory.attributes_for(
      :post, context: self, scope: self.class, overrides: { active: false }
    )
  end

  test ".attributes_for without context raises name error" do
    assert_raises(NameError) do
      FixtureFactory.attributes_for(:post, scope: self.class, overrides: {})
    end
  end

  test ".attributes_for without scope raises argument error" do
    assert_raises(ArgumentError) do
      FixtureFactory.attributes_for(:post, context: self, overrides: {})
    end
  end

  test ".attributes_for with invalid fixture raises fixture error" do
    error = assert_raises(FixtureFactory::NotFoundError) do
      FixtureFactory.attributes_for(:blog, context: self, scope: self.class, overrides: {})
    end
    assert_equal <<~MSG.squish, error.message
      No factory named "blog".
      Did you forget to define it?
      https://github.com/Shopify/fixture_factory/blob/master/README.md#definition
    MSG
  end

  test ".build returns new model" do
    new_post = Post.new(post_factory_attributes)
    assert_equal new_post, FixtureFactory.build(
      :post, context: self, scope: self.class, overrides: {}
    )
  end

  test ".build with overrides returns new model" do
    new_post = Post.new(post_factory_attributes.merge(title: "Test"))
    assert_equal new_post, FixtureFactory.build(
      :post, context: self, scope: self.class, overrides: { title: "Test" }
    )
  end

  test ".build without context raises name error" do
    assert_raises(NameError) do
      FixtureFactory.build(:post, scope: self.class, overrides: {})
    end
  end

  test ".build without scope raises argument error" do
    assert_raises(ArgumentError) do
      FixtureFactory.build(:post, context: self, overrides: {})
    end
  end

  test ".build with invalid fixture raises fixture error" do
    error = assert_raises(FixtureFactory::NotFoundError) do
      FixtureFactory.build(:user, context: self, scope: self.class, overrides: {})
    end
    assert_equal <<~MSG.squish, error.message
      No factory named "user". Did you forget to define it?
      https://github.com/Shopify/fixture_factory/blob/master/README.md#definition
    MSG
  end

  test ".create returns attributes of a model" do
    post = Post.create(post_factory_attributes)
    assert_equal post, FixtureFactory.create(
      :post, context: self, scope: self.class, overrides: {}
    )
  end

  test ".create with overrides returns new model" do
    post = Post.create(post_factory_attributes.merge(body: "Body"))
    assert_equal post, FixtureFactory.create(
      :post, context: self, scope: self.class, overrides: { body: "Body" }
    )
  end

  test ".create without context raises name error" do
    assert_raises(NameError) do
      FixtureFactory.create(:post, scope: self.class, overrides: {})
    end
  end

  test ".create without scope raises argument error" do
    assert_raises(ArgumentError) do
      FixtureFactory.create(:post, context: self, overrides: {})
    end
  end

  test ".create with invalid fixture raises fixture error" do
    error = assert_raises(FixtureFactory::NotFoundError) do
      FixtureFactory.create(:comment, context: self, scope: self.class, overrides: {})
    end
    assert_equal <<~MSG.squish, error.message
      No factory named "comment". Did you forget to define it?
      https://github.com/Shopify/fixture_factory/blob/master/README.md#definition
    MSG
  end

  test ".evaluate runs block in a provided context" do
    block = proc { hash }
    context = Module.new do
      mattr_accessor(:hash) { { some: :hash } }
    end
    result = FixtureFactory.evaluate(block, context: context)
    assert_equal context.hash, result
  end

  test ".evaluate casts block result to a hash" do
    hashlike = [[:some, :hash]]
    block    = proc { hashlike }
    result   = FixtureFactory.evaluate(block, context: self)
    assert_equal hashlike.to_h, result
  end

  test ".evaluate accepts optional arguments" do
    args     = [:foo]
    block    = proc { |*block_args| { args: block_args } }
    result   = FixtureFactory.evaluate(block, args: args, context: self)
    assert_equal Hash(args: args), result
  end

  private

  def post_factory_attributes
    {
      title: "Sample Post",
      body: "This is a test.",
      active: true,
    }
  end
end
