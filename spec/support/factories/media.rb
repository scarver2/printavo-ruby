# spec/support/factories/media.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_production_file_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'url' => Faker::Internet.url,
      'filename' => "#{Faker::Lorem.word}.pdf",
      'createdAt' => Faker::Time.backward(days: 30).iso8601
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_mockup_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'url' => Faker::Internet.url,
      'position' => Faker::Number.between(from: 1, to: 10),
      'createdAt' => Faker::Time.backward(days: 30).iso8601
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_email_template_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => Faker::Lorem.words(number: 3).join(' ').capitalize,
      'subject' => Faker::Lorem.sentence,
      'body' => Faker::Lorem.paragraph
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_custom_address_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => Faker::Company.name,
      'address' => Faker::Address.street_address,
      'city' => Faker::Address.city,
      'state' => Faker::Address.state_abbr,
      'zip' => Faker::Address.zip_code
    }.merge(overrides.transform_keys(&:to_s))
  end
end
