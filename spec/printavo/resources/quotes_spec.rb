# spec/printavo/resources/quotes_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Quotes do
  subject(:resource) { described_class.new(graphql) }

  let(:graphql) { instance_double(Printavo::GraphqlClient) }
  let(:quote_data) { fake_order_attrs.merge('total' => '125.50') }
  let(:page_info) { { 'hasNextPage' => false, 'endCursor' => nil } }

  it 'lists quote models through the documented quotes query' do
    allow(graphql).to receive(:query)
      .and_return('quotes' => { 'nodes' => [quote_data], 'pageInfo' => page_info })

    expect(resource.all).to all(be_a(Printavo::Quote))
  end

  it 'finds a quote through the documented quote query' do
    allow(graphql).to receive(:query).and_return('quote' => quote_data)

    expect(resource.find(42)).to be_a(Printavo::Quote)
    expect(graphql).to have_received(:query).with(described_class::FIND_QUERY,
                                                  variables: { id: '42' })
  end
end
