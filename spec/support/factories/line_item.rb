# spec/support/factories/line_item.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_line_item_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => Faker::Commerce.product_name,
      'quantity' => Faker::Number.between(from: 1, to: 500),
      'price' => Faker::Commerce.price(range: 1.0..100.0).to_s,
      'taxable' => false
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_line_item_group_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => Faker::Commerce.department,
      'description' => Faker::Lorem.sentence
    }.merge(overrides.transform_keys(&:to_s))
  end
end
