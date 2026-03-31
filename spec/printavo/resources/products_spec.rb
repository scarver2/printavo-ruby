# spec/printavo/resources/products_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Products do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:product_data) { fake_product_attrs }
    let(:response_data) do
      { 'products' => {
        'nodes' => [product_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all).to all(be_a(Printavo::Product)) }
    it { expect(resource.all.first.sku).to eq(product_data['sku']) }
  end

  describe '#find' do
    let(:product_data) { fake_product_attrs('id' => '70') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '70' })
        .and_return('product' => product_data)
    end

    it { expect(resource.find('70')).to be_a(Printavo::Product) }
    it { expect(resource.find('70').id).to eq('70') }
  end
end
