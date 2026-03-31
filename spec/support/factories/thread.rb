# spec/support/factories/thread.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_thread_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'subject' => Faker::Lorem.sentence(word_count: 4),
      'createdAt' => Faker::Time.backward(days: 30).iso8601,
      'updatedAt' => Faker::Time.backward(days: 7).iso8601
    }.merge(overrides.transform_keys(&:to_s))
  end
end
