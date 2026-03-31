# spec/support/factories/order.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_order_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'nickname' => Faker::Lorem.word.capitalize,
      'totalPrice' => Faker::Commerce.price(range: 50.0..5000.0).to_s,
      'status' => { 'id' => '1', 'name' => 'In Production', 'color' => '#ff6600' },
      'customer' => fake_customer_attrs
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
end
