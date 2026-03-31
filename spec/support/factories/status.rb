# spec/support/factories/status.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_status_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 3).to_s,
      'name' => Faker::Lorem.words(number: 2).map(&:capitalize).join(' '),
      'color' => Faker::Color.hex_color
    }.merge(overrides.transform_keys(&:to_s))
  end
end
