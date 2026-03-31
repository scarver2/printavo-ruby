# spec/support/factories/job.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_job_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => Faker::Commerce.product_name,
      'quantity' => Faker::Number.between(from: 1, to: 500),
      'price' => Faker::Commerce.price(range: 5.0..50.0).to_s,
      'taxable' => [true, false].sample
    }.merge(overrides.transform_keys(&:to_s))
  end
end
