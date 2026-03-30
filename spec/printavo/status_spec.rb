# spec/printavo/status_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Status do
  subject(:status) { described_class.new(attrs) }

  let(:attrs) do
    { 'id' => '42', 'name' => 'In Production', 'color' => '#ff6600' }
  end

  describe '#id' do
    it 'returns the id' do
      expect(status.id).to eq('42')
    end
  end

  describe '#name' do
    it 'returns the name' do
      expect(status.name).to eq('In Production')
    end
  end

  describe '#color' do
    it 'returns the hex color' do
      expect(status.color).to eq('#ff6600')
    end
  end

  describe '#key' do
    it 'normalizes the name to a snake_case symbol' do
      expect(status.key).to eq(:in_production)
    end

    it 'handles single-word names' do
      s = described_class.new('name' => 'Pending')
      expect(s.key).to eq(:pending)
    end

    it 'returns nil when name is nil' do
      s = described_class.new('id' => '1')
      expect(s.key).to be_nil
    end

    it 'matches Order#status_key for the same status name' do
      order = Printavo::Order.new(
        'id' => '1', 'nickname' => 'Test',
        'status' => { 'id' => '42', 'name' => 'In Production', 'color' => '#ff6600' }
      )
      expect(status.key).to eq(order.status_key)
    end
  end

  describe '#to_h' do
    it 'returns the attributes hash' do
      expect(status.to_h).to eq(attrs)
    end
  end
end
