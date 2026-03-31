# spec/support/factories/account.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_account_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 4).to_s,
      'companyName' => Faker::Company.name,
      'companyEmail' => Faker::Internet.email,
      'phone' => Faker::PhoneNumber.phone_number,
      'website' => Faker::Internet.url,
      'logoUrl' => nil,
      'locale' => 'en-US'
    }.merge(overrides.transform_keys(&:to_s))
  end
end
