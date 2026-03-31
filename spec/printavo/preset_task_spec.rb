# spec/printavo/preset_task_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::PresetTask do
  subject(:preset_task) { described_class.new(fake_preset_task_attrs) }

  it { expect(preset_task.id).to be_a(String) }
  it { expect(preset_task.body).to be_a(String) }
  it { expect(preset_task.due_offset_days).to be_a(Integer) }
  it { expect(preset_task.assignee).to be_nil }
end
