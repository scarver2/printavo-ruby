# spec/support/factories/fee.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_fee_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => Faker::Commerce.department,
      'amount' => Faker::Commerce.price(range: 1.0..500.0).to_s,
      'taxable' => false
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_expense_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => Faker::Commerce.material,
      'amount' => Faker::Commerce.price(range: 1.0..500.0).to_s,
      'category' => Faker::Commerce.department
    }.merge(overrides.transform_keys(&:to_s))
  end
end
