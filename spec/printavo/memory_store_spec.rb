# spec/printavo/memory_store_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::MemoryStore do
  subject(:store) { described_class.new }

  describe '#fetch' do
    context 'when the key is not cached' do
      it 'calls the block and returns its value' do
        result = store.fetch('key') { 'value' } # rubocop:disable Style/RedundantFetchBlock
        expect(result).to eq('value')
      end

      it 'stores the value for subsequent reads' do
        store.fetch('key') { 'value' } # rubocop:disable Style/RedundantFetchBlock
        calls = 0
        store.fetch('key') do
          calls += 1
          'other'
        end
        expect(calls).to eq(0)
      end
    end

    context 'when the key is already cached' do
      before { store.fetch('key') { 'cached' } } # rubocop:disable Style/RedundantFetchBlock

      it 'returns the cached value without calling the block' do
        block_called = false
        result = store.fetch('key') do
          block_called = true
          'new'
        end
        expect(result).to eq('cached')
        expect(block_called).to be false
      end
    end

    context 'with expires_in' do
      it 'serves the cached value before expiry' do
        store.fetch('key', expires_in: 60) { 'value' }
        result = store.fetch('key', expires_in: 60) { 'new' }
        expect(result).to eq('value')
      end

      it 'recomputes after expiry' do
        store.fetch('key', expires_in: 0.001) { 'old' }
        sleep 0.002
        result = store.fetch('key', expires_in: 60) { 'fresh' }
        expect(result).to eq('fresh')
      end
    end

    context 'with different keys' do
      it 'stores values independently' do
        store.fetch('a') { 1 } # rubocop:disable Style/RedundantFetchBlock
        store.fetch('b') { 2 } # rubocop:disable Style/RedundantFetchBlock
        expect(store.fetch('a') { 99 }).to eq(1) # rubocop:disable Style/RedundantFetchBlock
        expect(store.fetch('b') { 99 }).to eq(2) # rubocop:disable Style/RedundantFetchBlock
      end
    end
  end

  describe '#delete' do
    before { store.fetch('key') { 'value' } } # rubocop:disable Style/RedundantFetchBlock

    it 'removes the key so the next fetch calls the block' do
      store.delete('key')
      calls = 0
      store.fetch('key') do
        calls += 1
        'fresh'
      end
      expect(calls).to eq(1)
    end

    it 'returns nil' do
      expect(store.delete('key')).to be_nil
    end

    it 'is a no-op for missing keys' do
      expect { store.delete('no_such_key') }.not_to raise_error
    end
  end
end
