# spec/support/factories/contact.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_contact_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'firstName' => Faker::Name.first_name,
      'lastName' => Faker::Name.last_name,
      'fullName' => Faker::Name.name,
      'email' => Faker::Internet.email,
      'phone' => Faker::PhoneNumber.phone_number,
      'fax' => nil
    }.merge(overrides.transform_keys(&:to_s))
  end
end
