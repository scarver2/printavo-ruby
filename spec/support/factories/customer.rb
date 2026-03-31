# spec/support/factories/customer.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_customer_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'firstName' => Faker::Name.first_name,
      'lastName' => Faker::Name.last_name,
      'email' => Faker::Internet.email,
      'phone' => Faker::PhoneNumber.phone_number,
      'company' => Faker::Company.name
    }.merge(overrides.transform_keys(&:to_s))
  end

  # Simulates the shape returned by customerCreate/customerUpdate mutations:
  # companyName at top level, contact fields nested under primaryContact.
  def fake_customer_mutation_response(overrides = {})
    contact = fake_customer_attrs
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'companyName' => Faker::Company.name,
      'primaryContact' => {
        'id' => Faker::Number.number(digits: 6).to_s,
        'firstName' => contact['firstName'],
        'lastName' => contact['lastName'],
        'email' => contact['email'],
        'phone' => contact['phone']
      }
    }.merge(overrides.transform_keys(&:to_s))
  end
end
