# spec/support/factories/inquiry.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_inquiry_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'nickname' => Faker::Lorem.word.capitalize,
      'totalPrice' => Faker::Commerce.price(range: 50.0..5000.0).to_s,
      'status' => { 'id' => '2', 'name' => 'New Inquiry', 'color' => '#3399ff' },
      'customer' => fake_customer_attrs
    }.merge(overrides.transform_keys(&:to_s))
  end
end
