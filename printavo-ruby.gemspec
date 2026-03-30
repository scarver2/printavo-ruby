# printavo-ruby.gemspec
require_relative 'lib/printavo/version'

Gem::Specification.new do |spec|
  spec.name        = 'printavo-ruby'
  spec.version     = Printavo::VERSION
  spec.authors     = ['Stan Carver II']
  spec.email       = ['stan@stancarver.com']
  spec.summary     = 'Ruby SDK for the Printavo GraphQL API'
  spec.description = <<~DESC
    A framework-agnostic Ruby SDK for Printavo supporting the v2 GraphQL API.
    Provides both a resource-oriented interface (client.orders.all) and rich domain
    models (Printavo::Order), plus raw GraphQL access and Rack-compatible webhook
    verification. Built to bridge Printavo with external operational systems.
  DESC
  spec.homepage    = 'https://github.com/scarver2/printavo-ruby'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.0'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/scarver2/printavo-ruby/issues',
    'changelog_uri' => 'https://github.com/scarver2/printavo-ruby/blob/master/docs/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/scarver2/printavo-ruby#readme',
    'source_code_uri' => 'https://github.com/scarver2/printavo-ruby',
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir[
    'lib/**/*.rb',
    'docs/**/*.md',
    'LICENSE',
    'README.md'
  ]

  spec.require_paths = ['lib']

  spec.add_dependency 'faraday',       '~> 2.0'
  spec.add_dependency 'faraday-retry', '~> 2.0'

  spec.add_development_dependency 'faker',               '~> 3.0'
  spec.add_development_dependency 'guard',               '~> 2.0'
  spec.add_development_dependency 'guard-rspec',         '~> 4.0'
  spec.add_development_dependency 'guard-rubocop',       '~> 1.0'
  spec.add_development_dependency 'rake',                '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.6'
  spec.add_development_dependency 'rubocop',             '~> 1.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.0'
  spec.add_development_dependency 'rubocop-rake',        '~> 0.6'
  spec.add_development_dependency 'rubocop-rspec',       '~> 3.0'
  spec.add_development_dependency 'simplecov',           '~> 0.22'
  spec.add_development_dependency 'simplecov-lcov',      '~> 0.8'
  spec.add_development_dependency 'vcr',                 '~> 6.0'
  spec.add_development_dependency 'webmock',             '~> 3.0'
end
