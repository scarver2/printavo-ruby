# spec/printavo/resources/custom_addresses_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::CustomAddresses do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:addr_data) { fake_custom_address_attrs }
    let(:response_data) do
      { 'order' => { 'customAddresses' => {
        'nodes' => [addr_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { orderId: '99', first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all(order_id: '99')).to all(be_a(Printavo::CustomAddress)) }
  end

  describe '#find' do
    let(:addr_data) { fake_custom_address_attrs('id' => '40') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '40' })
        .and_return('customAddress' => addr_data)
    end

    it { expect(resource.find('40')).to be_a(Printavo::CustomAddress) }
    it { expect(resource.find('40').id).to eq('40') }
  end

  describe '#create' do
    let(:addr_data) { fake_custom_address_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('customAddressCreate' => addr_data)
    end

    it { expect(resource.create(order_id: '99', name: 'Ship To')).to be_a(Printavo::CustomAddress) }
  end

  describe '#creates' do
    let(:addrs_data) { [fake_custom_address_attrs, fake_custom_address_attrs] }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATES_MUTATION, variables: anything)
        .and_return('customAddressCreates' => addrs_data)
    end

    it { expect(resource.creates([{ name: 'A' }, { name: 'B' }])).to all(be_a(Printavo::CustomAddress)) }
  end

  describe '#update' do
    let(:addr_data) { fake_custom_address_attrs('id' => '40') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('customAddressUpdate' => addr_data)
    end

    it { expect(resource.update('40', name: 'Updated')).to be_a(Printavo::CustomAddress) }
  end

  describe '#updates' do
    let(:addrs_data) { [fake_custom_address_attrs, fake_custom_address_attrs] }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATES_MUTATION, variables: anything)
        .and_return('customAddressUpdates' => addrs_data)
    end

    it { expect(resource.updates([{ id: '1', name: 'A' }])).to all(be_a(Printavo::CustomAddress)) }
  end

  describe '#delete' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETE_MUTATION, variables: { id: '40' })
        .and_return('customAddressDelete' => { 'id' => '40' })
    end

    it { expect(resource.delete('40')).to be_nil }
  end

  describe '#deletes' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETES_MUTATION, variables: { ids: %w[1 2] })
        .and_return('customAddressDeletes' => [{ 'id' => '1' }, { 'id' => '2' }])
    end

    it { expect(resource.deletes([1, 2])).to be_nil }
  end
end
