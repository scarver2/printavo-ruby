# spec/printavo/resources/merch_orders_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::MerchOrders do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:order_data) { fake_merch_order_attrs }
    let(:response_data) do
      { 'merchOrders' => {
        'nodes' => [order_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all).to all(be_a(Printavo::MerchOrder)) }
    it { expect(resource.all.first.status).to eq(order_data['status']) }
  end

  describe '#find' do
    let(:order_data) { fake_merch_order_attrs('id' => '60') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '60' })
        .and_return('merchOrder' => order_data)
    end

    it { expect(resource.find('60')).to be_a(Printavo::MerchOrder) }
    it { expect(resource.find('60').id).to eq('60') }
  end
end
