# spec/support/factories/task.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_task_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'body' => Faker::Lorem.sentence,
      'dueAt' => Faker::Date.forward(days: 14).iso8601,
      'completedAt' => nil,
      'assignee' => nil
    }.merge(overrides.transform_keys(&:to_s))
  end
end
