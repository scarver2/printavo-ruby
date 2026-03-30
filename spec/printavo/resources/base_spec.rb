# spec/printavo/resources/base_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Base do
  subject(:resource) { stub_resource_class.new(nil) }

  # Multi-page stub: three pages of data keyed by cursor.
  let(:stub_resource_class) do
    Class.new(described_class) do
      def self.name = 'StubResource'

      private

      def fetch_page(after: nil, **) = page_for(after)

      def page_for(cursor)
        data = { nil => [%w[a b], true, 'c1'], 'c1' => [%w[c d], true, 'c2'], 'c2' => [%w[e], false, nil] }
        records, more, next_cursor = data.fetch(cursor, [[], false, nil])
        Printavo::Page.new(records: records, has_next_page: more, end_cursor: next_cursor)
      end
    end
  end

  # Empty stub: always returns a single empty page.
  let(:empty_resource_class) do
    Class.new(described_class) do
      def self.name = 'EmptyResource'

      private

      def fetch_page(**)
        Printavo::Page.new(records: [], has_next_page: false, end_cursor: nil)
      end
    end
  end

  describe '#each_page' do
    it 'yields each page of records in order' do
      pages = []
      resource.each_page { |records| pages << records }
      expect(pages).to eq([%w[a b], %w[c d], %w[e]])
    end

    it 'stops after the last page' do
      call_count = 0
      resource.each_page { call_count += 1 }
      expect(call_count).to eq(3)
    end

    it 'yields nothing for an empty resource' do
      pages = []
      empty_resource_class.new(nil).each_page { |recs| pages << recs }
      expect(pages).to eq([[]])
    end
  end

  describe '#all_pages' do
    it 'returns all records across all pages as a flat array' do
      expect(resource.all_pages).to eq(%w[a b c d e])
    end

    it 'returns an empty array when there are no records' do
      expect(empty_resource_class.new(nil).all_pages).to eq([])
    end
  end

  describe '#fetch_page (not implemented in Base)' do
    subject(:bare) { described_class.new(nil) }

    it 'raises NotImplementedError' do
      expect { bare.send(:fetch_page) }.to raise_error(NotImplementedError)
    end
  end
end
