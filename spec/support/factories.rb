# spec/support/factories.rb
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

  # Simulates the shape returned by quoteCreate/quoteUpdate/statusUpdate mutations:
  # uses `total` instead of `totalPrice`.
  def fake_order_mutation_response(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'nickname' => Faker::Lorem.word.capitalize,
      'total' => Faker::Commerce.price(range: 50.0..5000.0).to_s,
      'status' => { 'id' => '1', 'name' => 'In Production', 'color' => '#ff6600' },
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

  def fake_invoice_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'nickname' => Faker::Lorem.word.capitalize,
      'total' => Faker::Commerce.price(range: 50.0..5000.0).to_s,
      'amountPaid' => Faker::Commerce.price(range: 0.0..500.0).to_s,
      'amountOutstanding' => Faker::Commerce.price(range: 0.0..500.0).to_s,
      'paidInFull' => false,
      'invoiceAt' => Faker::Date.backward(days: 30).iso8601,
      'paymentDueAt' => Faker::Date.forward(days: 30).iso8601,
      'status' => { 'id' => '3', 'name' => 'Invoice', 'color' => '#009900' },
      'contact' => fake_contact_attrs
    }.merge(overrides.transform_keys(&:to_s))
  end

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

  def stub_graphql_response(data)
    { 'data' => data }.to_json
  end
end

RSpec.configure do |config|
  config.include Factories
end
