# spec/support/factories/imprint.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_imprint_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => Faker::Lorem.words(number: 2).join(' ').capitalize,
      'position' => %w[front back left_chest].sample,
      'colors' => Faker::Number.between(from: 1, to: 6)
    }.merge(overrides.transform_keys(&:to_s))
  end
end
