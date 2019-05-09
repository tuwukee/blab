# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("../lib", __FILE__)

require "blab/version"

Gem::Specification.new do |s|
  s.name        = "blab"
  s.version     = Blab::VERSION
  s.date        = "2019-05-01"
  s.summary     = "Blab"
  s.description = "A debugging tool"
  s.authors     = ["Yulia Oletskaya"]
  s.email       = "yulia.oletskaya@gmail.com"
  s.homepage    = "http://rubygems.org/gems/blab"
  s.license     = "MIT"

  s.add_development_dependency("debase-ruby_core_source", "~> 0.10")

  s.extensions = ["ext/extconf.rb"]

  s.files         = Dir["lib/**/*", "LICENSE", "README.md"]
  s.test_files    = Dir["test/*", "test/**/*"]
  s.require_paths = ["lib"]
end
