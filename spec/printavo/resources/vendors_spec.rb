# spec/printavo/resources/vendors_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Vendors do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:vendor_data) { fake_vendor_attrs }
    let(:response_data) do
      { 'vendors' => {
        'nodes' => [vendor_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all).to all(be_a(Printavo::Vendor)) }
    it { expect(resource.all.first.name).to eq(vendor_data['name']) }
  end

  describe '#find' do
    let(:vendor_data) { fake_vendor_attrs('id' => '20') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '20' })
        .and_return('vendor' => vendor_data)
    end

    it { expect(resource.find('20')).to be_a(Printavo::Vendor) }
    it { expect(resource.find('20').id).to eq('20') }
  end
end
