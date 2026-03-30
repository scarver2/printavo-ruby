# spec/printavo/page_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Page do
  let(:records)   { %w[alpha beta] }
  let(:page)      { described_class.new(records: records, has_next_page: true, end_cursor: 'abc123') }
  let(:last_page) { described_class.new(records: [], has_next_page: false, end_cursor: nil) }

  describe '#records' do
    it 'returns the array of records' do
      expect(page.records).to eq(records)
    end
  end

  describe '#has_next_page' do
    it 'returns true when there is a next page' do
      expect(page.has_next_page).to be true
    end

    it 'returns false on the last page' do
      expect(last_page.has_next_page).to be false
    end
  end

  describe '#end_cursor' do
    it 'returns the cursor string' do
      expect(page.end_cursor).to eq('abc123')
    end

    it 'returns nil on the last page' do
      expect(last_page.end_cursor).to be_nil
    end
  end

  describe '#to_a' do
    it 'delegates to records' do
      expect(page.to_a).to eq(records)
    end
  end

  describe '#size' do
    it 'returns the number of records' do
      expect(page.size).to eq(2)
    end

    it 'returns 0 for an empty page' do
      expect(last_page.size).to eq(0)
    end
  end

  describe '#empty?' do
    it 'returns false when records are present' do
      expect(page.empty?).to be false
    end

    it 'returns true when records are absent' do
      expect(last_page.empty?).to be true
    end
  end
end
