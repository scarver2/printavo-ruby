# spec/printavo/resources/quotes_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Quotes do
  subject(:resource) { described_class.new(graphql) }

  let(:graphql) { instance_double(Printavo::GraphqlClient) }
  let(:quote_data) do
    fake_order_attrs.reject { |key,| key == 'updatedAt' }.merge(
      'total' => '125.50',
      'timestamps' => { 'updatedAt' => '2026-10-03T12:00:00Z' }
    )
  end
  let(:page_info) { { 'hasNextPage' => false, 'endCursor' => nil } }

  it 'selects the documented nested update timestamp' do
    expect(described_class::ALL_QUERY).to include("createdAt\n      timestamps { updatedAt }")
    expect(described_class::FIND_QUERY).to include("createdAt\n    timestamps { updatedAt }")
  end

  it 'lists quote models through the documented quotes query' do
    allow(graphql).to receive(:query)
      .and_return('quotes' => { 'nodes' => [quote_data], 'pageInfo' => page_info })

    quotes = resource.all

    expect(quotes).to all(be_a(Printavo::Quote))
    expect(quotes.map(&:updated_at)).to all(eq('2026-10-03T12:00:00Z'))
  end

  it 'finds a quote through the documented quote query' do
    allow(graphql).to receive(:query).and_return('quote' => quote_data)

    expect(resource.find(42)).to be_a(Printavo::Quote).and have_attributes(updated_at: '2026-10-03T12:00:00Z')
    expect(graphql).to have_received(:query).with(described_class::FIND_QUERY,
                                                  variables: { id: '42' })
  end
end
