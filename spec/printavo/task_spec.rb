# spec/printavo/task_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Task do
  subject(:task) { described_class.new(fake_task_attrs) }

  it { expect(task.id).to be_a(String) }
  it { expect(task.body).to be_a(String) }
  it { expect(task.due_at).to be_a(String) }
  it { expect(task.completed_at).to be_nil }
  it { expect(task.completed?).to be false }
  it { expect(task.assignee).to be_nil }

  describe '#completed?' do
    it 'returns true when completedAt is present' do
      t = described_class.new(fake_task_attrs('completedAt' => '2026-03-30T12:00:00Z'))
      expect(t.completed?).to be true
    end
  end
end
