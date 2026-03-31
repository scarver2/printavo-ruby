# spec/printavo/preset_task_group_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::PresetTaskGroup do
  subject(:group) { described_class.new(fake_preset_task_group_attrs) }

  it { expect(group.id).to be_a(String) }
  it { expect(group.name).to be_a(String) }

  describe '#tasks' do
    it 'returns an array of PresetTask instances' do
      expect(group.tasks).to all(be_a(Printavo::PresetTask))
    end

    it 'returns an empty array when tasks are absent' do
      g = described_class.new(fake_preset_task_group_attrs('tasks' => nil))
      expect(g.tasks).to eq([])
    end
  end
end
