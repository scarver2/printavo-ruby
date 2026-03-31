# spec/printavo/resources/merch_stores_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::MerchStores do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:store_data) { fake_merch_store_attrs }
    let(:response_data) do
      { 'merchStores' => {
        'nodes' => [store_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all).to all(be_a(Printavo::MerchStore)) }
    it { expect(resource.all.first.name).to eq(store_data['name']) }
  end

  describe '#find' do
    let(:store_data) { fake_merch_store_attrs('id' => '50') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '50' })
        .and_return('merchStore' => store_data)
    end

    it { expect(resource.find('50')).to be_a(Printavo::MerchStore) }
    it { expect(resource.find('50').id).to eq('50') }
  end
end
