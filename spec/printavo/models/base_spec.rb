# spec/printavo/models/base_spec.rb
require 'spec_helper'

RSpec.describe Printavo::Models::Base do
  subject(:model) { described_class.new('id' => '1', 'name' => 'Acme', 'nested' => { 'key' => 'val' }) }

  describe '#[]' do
    it 'retrieves a value by string key' do
      expect(model['id']).to eq('1')
    end

    it 'retrieves a value by symbol key' do
      expect(model[:name]).to eq('Acme')
    end

    it 'returns nil for a missing key' do
      expect(model['missing']).to be_nil
    end
  end

  describe '#dig' do
    it 'retrieves nested values' do
      expect(model.dig('nested', 'key')).to eq('val')
    end

    it 'returns nil when an intermediate key is missing' do
      expect(model.dig('missing', 'key')).to be_nil
    end

    it 'returns nil when traversal hits a non-Hash value' do
      expect(model.dig('id', 'anything')).to be_nil
    end
  end

  describe '#to_h' do
    it 'returns a copy of the attributes hash' do
      expect(model.to_h).to eq('id' => '1', 'name' => 'Acme', 'nested' => { 'key' => 'val' })
    end

    it 'returns a duplicate, not the internal reference' do
      hash = model.to_h
      hash['extra'] = 'added'
      expect(model['extra']).to be_nil
    end
  end

  describe '#==' do
    it 'is equal to another instance with identical attributes' do
      other = described_class.new('id' => '1', 'name' => 'Acme', 'nested' => { 'key' => 'val' })
      expect(model).to eq(other)
    end

    it 'is not equal to an instance with different attributes' do
      other = described_class.new('id' => '2')
      expect(model).not_to eq(other)
    end

    it 'is not equal to an object of a different class' do
      expect(model).not_to eq('id' => '1', 'name' => 'Acme', 'nested' => { 'key' => 'val' })
    end
  end

  describe '#inspect' do
    it 'includes the class name' do
      expect(model.inspect).to include('Printavo::Models::Base')
    end

    it 'includes the attributes' do
      expect(model.inspect).to include('"id" => "1"')
    end
  end
end
