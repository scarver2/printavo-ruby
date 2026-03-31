# spec/support/factories/product.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_product_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => Faker::Commerce.product_name,
      'sku' => Faker::Alphanumeric.alphanumeric(number: 8).upcase,
      'description' => Faker::Lorem.sentence
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_pricing_matrix_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => "#{Faker::Commerce.department} Matrix"
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_category_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 4).to_s,
      'name' => Faker::Commerce.department
    }.merge(overrides.transform_keys(&:to_s))
  end
end
