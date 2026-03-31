# spec/spec_helper.rb
# frozen_string_literal: true

require 'simplecov'
require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.output_directory        = 'coverage'
  c.lcov_file_name          = 'lcov.info'
end

SimpleCov.start do
  formatter SimpleCov::Formatter::MultiFormatter.new([
                                                       SimpleCov::Formatter::HTMLFormatter,
                                                       SimpleCov::Formatter::LcovFormatter
                                                     ])
  add_filter '/spec/'
  minimum_coverage 90
end

require 'printavo'
require 'webmock/rspec'

require_relative 'support/vcr'
Dir[File.join(__dir__, 'support/factories/*.rb')].each { |f| require f }

PRINTAVO_TEST_EMAIL = ENV.fetch('PRINTAVO_EMAIL', 'demo@example.com')
PRINTAVO_TEST_TOKEN = ENV.fetch('PRINTAVO_TOKEN', 'test_token')
PRINTAVO_API_URL    = 'https://www.printavo.com/api/v2'

RSpec.configure do |config|
  config.include Factories

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end
