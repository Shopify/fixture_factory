# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fixture_factory/version"

Gem::Specification.new do |spec|
  spec.name          = "fixture_factory"
  spec.version       = FixtureFactory::VERSION
  spec.authors       = ["Shopify Inc."]
  spec.email         = ["gems@shopify.com"]
  spec.license       = "MIT"

  spec.summary       = "Factories via fixtures"

  spec.homepage      = "https://github.com/Shopify/fixture_factory"

  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.7.0"

  spec.add_dependency("activemodel", ">= 5.2")
  spec.add_dependency("activerecord", ">= 5.2")
  spec.add_dependency("activesupport", ">= 5.2")

  spec.add_development_dependency("bundler")
  spec.add_development_dependency("byebug")
  spec.add_development_dependency("minitest")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("sqlite3")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
end
