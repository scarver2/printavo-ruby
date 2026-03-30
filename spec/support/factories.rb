# spec/support/factories.rb
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

  def fake_status_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 3).to_s,
      'name' => Faker::Lorem.words(number: 2).map(&:capitalize).join(' '),
      'color' => Faker::Color.hex_color
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_order_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'nickname' => Faker::Lorem.word.capitalize,
      'totalPrice' => Faker::Commerce.price(range: 50.0..5000.0).to_s,
      'status' => { 'id' => '1', 'name' => 'In Production', 'color' => '#ff6600' },
      'customer' => fake_customer_attrs
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_inquiry_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'nickname' => Faker::Lorem.word.capitalize,
      'totalPrice' => Faker::Commerce.price(range: 50.0..5000.0).to_s,
      'status' => { 'id' => '2', 'name' => 'New Inquiry', 'color' => '#3399ff' },
      'customer' => fake_customer_attrs
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_job_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => Faker::Commerce.product_name,
      'quantity' => Faker::Number.between(from: 1, to: 500),
      'price' => Faker::Commerce.price(range: 5.0..50.0).to_s,
      'taxable' => [true, false].sample
    }.merge(overrides.transform_keys(&:to_s))
  end

  def stub_graphql_response(data)
    { 'data' => data }.to_json
  end
end

RSpec.configure do |config|
  config.include Factories
end
