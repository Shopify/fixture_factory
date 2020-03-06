# FixtureFactory

FixtureFactory is an attempt to merge concepts from [Rails Fixtures](http://api.rubyonrails.org/v5.2.0/classes/ActiveRecord/FixtureSet.html),
[Hermes Builders](https://github.com/plataformatec/hermes/blob/master/lib/hermes/builders.rb),
and [Factory Bot Factories](https://github.com/thoughtbot/factory_bot) to bridge the gap between factories and fixtures.

## Fixtures

Fixtures are fast, simple, and an easy way to seed your test database with sample data. Codebases that leverage fixtures
often have faster test runs than factory-based test suites. This is due to fixtures being loaded once whereas factories
build models for each test. Fixtures are also officially recommended over factories by the Rails core team.

Fixtures start to become a pain when you need to test models with complex state. Unlike factories, there's no simple way
to ask for a model, transform it, and start using it in one line (without using a helper method or similar).

For more information on fixtures, check out the [Rails guides](http://guides.rubyonrails.org/testing.html#the-low-down-on-fixtures).

## Factories

Factories make testing any model nearly painless. State differences are expressed in factory definitions through traits,
callbacks, and transient attributes. Factories are often paired with data generating libraries to add an extra degree of
verification to your tests.

As mentioned above, factories' biggest downside is the speed trade-off of building models for each test. There are also
added compatibility concerns with factories as they are not the officially recommended way of testing Rails apps.

For more information on factories, check out [FactoryBot's wiki](https://github.com/thoughtbot/factory_bot/wiki#factory_bot).

## Fixture Factories

Fixture Factories is *not* a fixture replacement. Rather, they are meant to compliment an existing suite of fixtures.
When testing models with complex state, a fixture factory can:

- Provide a simple creation syntax that supports overrides
- Use existing fixtures as templates for fixtures factories
- Act as an alternative to redundant fixture definitions

## Definition

FixtureFactory definitions can be made by anything that includes `FixtureFactory::Registry`. Typically, this is a test
case class. Definitions are made with the `.define_factories` and `.fixture` method:

```ruby
class AccountTest < ActiveSupport::TestCase
  define_factories do
    fixture(:account)
    fixture(:enterprise_account, class: 'Account') do
      { plan: :enterprise }
    end
  end
end
```

## Naming

The name of your fixture is important. It infers the class (with `ActiveSupport::Inflector`) you'll be using, and the
fixture method you source fixtures from. Fixture with non-standard names can get around this problem 2 different ways:

1. Define a base fixture with a simple name and extend via `parent`:

```ruby
class RecipeTest < ActiveSupport::TestCase
  define_factories do
    fixture(:recipe) # infers "Recipe" and "recipes"
    fixture(:cake_recipe, parent: :recipe) do
      { name: "Cake" }
    end
  end
end
```

2. Use the `class` and `via` options to specify class and fixture method:

```ruby
class RecipeTest < ActiveSupport::TestCase
  define_factories do
    fixture(:cake_recipe, class: "Recipe", via: :recipes) do
      { name: "Cake" }
    end
  end
end
```

### Fixtures

The whole point of fixture factories is to complement a fixture suite. Typically, you'll want to link your factories to
fixtures. This is done with the `via` and `like` options:

```ruby
class UserTest < ActiveSupport::TestCase
  define_factories do
    fixture(:user, like: :bob)
    fixture(:admin_user, class: 'User', like: :bob, via: :users) do
      { role: :admin }
    end
  end
end
```

### Inheritance

There are two aspects of inheritance to factories definitions. Inheritance at the registry level, and inheritance at the
definition level. Registry subclasses inherit definitions from their superclass. Fixture factory definitions can specify
a `parent` factory to inherit options from. Here's an example:

```ruby
class ActiveSupport::TestCase
  define_factories do
    fixture(:address)
  end
end

class AddressTest < ActiveSupport::TestCase
  define_factories do
    fixture(:primary_address, parent: :address)
      { primary: true }
    end
  end
end
```

### Sequences

Factories often don't play well with uniqueness constraints. If you need to generate unique values in your factories,
consider using sequences. An auto-incrementing number is passed to every factory definition block which can be used to
seed unique values.

```ruby
class ArticleTest < ActiveSupport::TestCase
  define_factories do
    fixture(:article) do |count| # starts at 1
      { title: "Unique Article", slug: "article-#{count}" }
    end
  end
end
```

## Usage

FixtureFactory usage is easiest in registries that include `FixtureFactory::Methods`. This exposes several methods that
gives your tests superpowers.

### `attributes_for(name, overrides = {})`

Generates a hash of attributes given a factory name and an optional hash of override attributes.

```ruby
class UsersControllerTest < ActionDispatch::IntegrationTest
  define_factories do
    fixture(:user) do
      { email: 'user@example.com', admin: false }
    end
  end
  setup do
    @user_attributes = attributes_for(:user, admin: true)
    # => { email: "user@example.com", admin: true }
  end
end
```

### `attributes_for_list(name, count, overrides = {})`

Generates an array of hash attributes given a factory name, a count, and an optional hash of override attributes.

```ruby
class BooksControllerTest < ActionDispatch::IntegrationTest
  define_factories do
    fixture(:book) do
      { title: 'Ruby Under a Microscope' }
    end
  end
  setup do
    @book_attributes = attributes_for_list(:book, 2, title: "Why's Poignant Guide to Ruby")
    # => [{ title: "Why's Poignant Guide to Ruby" }, { title: "Why's Poignant Guide to Ruby" }]
  end
end
```

### `build(name, overrides = {})`

Generates an unpersisted instance of a model given a factory name and an optional hash of override attributes.

```ruby
class CourseTest < ActiveSupport::TestCase
  define_factories do
    fixture(:course) do
      { name: 'Rails for Zombies' }
    end
  end
  setup do
    @course = build(:course, name: 'Ruby Monk')
    # => #<Course:0x000 name: "Ruby Monk">
  end
end
```

### `build_list(name, count, overrides = {})`

Generates an array of unpersisted model instances given a factory name and an optional hash of override attributes.

```ruby
class PostTest < ActiveSupport::TestCase
  define_factories do
    fixture(:post) do
      { title: 'Rails 5.2' }
    end
  end
  setup do
    @post = build_list(:post, 2, title: 'Rails 6')
    # => [#<Post:0x000 id: nil, title: "Rails 6">, #<Post:0x000 id: nil, title: "Rails 6">]
  end
end
```

### `create(name, overrides = {})`

Generates a persisted model instance given a factory name and an optional hash of override attributes.

```ruby
class CommentTest < ActiveSupport::TestCase
  define_factories do
    fixture(:comment) do
      { content: 'Hello World!', post: build(:post) }
    end
  end
  setup do
    @comment = create(:comment, post: create(:post, title: 'Wow'))
    # => #<Comment:0x000 id: 1, title: "Hello World!", post_id: 1>
  end
end
```

### `create_list(name, count, overrides = {})`

Generates an array of persisted model instances given a factory name and an optional hash of override attributes.

```ruby
class BlogTest < ActiveSupport::TestCase
  define_factories do
    fixture(:blog) do
      { name: 'Giant Robots Smashing Into Other Giant Robots' }
    end
  end
  setup do
    @blog = create_list(:blog, 2, title: 'Riding Rails')
    # => [#<Blog:0x000 id: 1, title: "Riding Rails">, #<Blog:0x000 id: 2, title: "Riding Rails">]
  end
end
```
