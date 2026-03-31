# spec/printavo/resources/pricing_matrices_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::PricingMatrices do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:matrix_data) { fake_pricing_matrix_attrs }
    let(:response_data) do
      { 'pricingMatrices' => {
        'nodes' => [matrix_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all).to all(be_a(Printavo::PricingMatrix)) }
    it { expect(resource.all.first.name).to eq(matrix_data['name']) }
  end

  describe '#find' do
    let(:matrix_data) { fake_pricing_matrix_attrs('id' => '80') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '80' })
        .and_return('pricingMatrix' => matrix_data)
    end

    it { expect(resource.find('80')).to be_a(Printavo::PricingMatrix) }
    it { expect(resource.find('80').id).to eq('80') }
  end
end
