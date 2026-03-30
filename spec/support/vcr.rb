# spec/support/vcr.rb
# frozen_string_literal: true

require 'vcr'
require 'webmock/rspec'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = { record: :new_episodes }

  # Redact real credentials from recorded cassettes
  c.filter_sensitive_data('<PRINTAVO_EMAIL>') { ENV.fetch('PRINTAVO_EMAIL', 'demo@example.com') }
  c.filter_sensitive_data('<PRINTAVO_TOKEN>') { ENV.fetch('PRINTAVO_TOKEN', 'test_token_redacted') }

  c.before_record do |interaction|
    body = interaction.response.body
    next unless body.is_a?(String)

    # Sanitize PII — replace real TER customer data with Faker-style placeholders
    body.gsub!(/\b[A-Z][a-z]{1,15} [A-Z][a-z]{1,15}\b/, 'Acme Customer')
    body.gsub!(/[\w.+-]+@[\w-]+\.[a-z]{2,}/i, 'customer@example.com')
    body.gsub!(/\(?\d{3}\)?[-.\s]\d{3}[-.\s]\d{4}/, '555-867-5309')
    body.gsub!(/\+1[-.\s]?\(?\d{3}\)?[-.\s]\d{3}[-.\s]\d{4}/, '+1-555-867-5309')

    interaction.response.body = body
  end
end
