# spec/support/factories/people.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_user_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'firstName' => Faker::Name.first_name,
      'lastName' => Faker::Name.last_name,
      'email' => Faker::Internet.email
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_vendor_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => Faker::Company.name,
      'email' => Faker::Internet.email,
      'phone' => Faker::PhoneNumber.phone_number
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_contractor_profile_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => Faker::Name.name,
      'email' => Faker::Internet.email
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_delivery_method_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => %w[Pickup Shipping Delivery].sample
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_type_of_work_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => %w[Embroidery Screenprint DTG].sample
    }.merge(overrides.transform_keys(&:to_s))
  end
end
