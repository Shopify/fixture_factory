# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fixture_factory/version"

Gem::Specification.new do |spec|
  spec.name          = "fixture_factory"
  spec.version       = FixtureFactory::VERSION
  spec.authors       = ["Shopify Inc."]
  spec.email         = ["gems@shopify.com"]

  spec.summary       = "Factories via fixtures"

  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = %w(lib)

  spec.add_dependency("activerecord", ">= 5.2")
  spec.add_dependency("activemodel", ">= 5.2")
  spec.add_dependency("activesupport", ">= 5.2")

  spec.add_development_dependency("bundler")
  spec.add_development_dependency("sqlite3")
  spec.add_development_dependency("byebug")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("minitest")
end
