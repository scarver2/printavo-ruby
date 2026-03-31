# spec/support/factories/preset_task.rb
# frozen_string_literal: true

require 'faker'

module Factories
  def fake_preset_task_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'body' => Faker::Lorem.sentence,
      'dueOffsetDays' => Faker::Number.between(from: 1, to: 30),
      'assignee' => nil
    }.merge(overrides.transform_keys(&:to_s))
  end

  def fake_preset_task_group_attrs(overrides = {})
    {
      'id' => Faker::Number.number(digits: 6).to_s,
      'name' => Faker::Lorem.words(number: 3).join(' ').capitalize,
      'tasks' => [fake_preset_task_attrs, fake_preset_task_attrs]
    }.merge(overrides.transform_keys(&:to_s))
  end
end
