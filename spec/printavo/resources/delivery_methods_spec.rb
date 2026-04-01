# spec/printavo/resources/delivery_methods_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::DeliveryMethods do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:dm_data) { fake_delivery_method_attrs }
    let(:response_data) do
      { 'deliveryMethods' => {
        'nodes' => [dm_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all).to all(be_a(Printavo::DeliveryMethod)) }
    it { expect(resource.all.first.name).to eq(dm_data['name']) }
  end

  describe '#find' do
    let(:dm_data) { fake_delivery_method_attrs('id' => '40') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '40' })
        .and_return('deliveryMethod' => dm_data)
    end

    it { expect(resource.find('40')).to be_a(Printavo::DeliveryMethod) }
    it { expect(resource.find('40').id).to eq('40') }
  end

  describe '#create' do
    let(:dm_data) { fake_delivery_method_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('deliveryMethodCreate' => dm_data)
    end

    it { expect(resource.create(name: 'Rush Delivery')).to be_a(Printavo::DeliveryMethod) }
  end

  describe '#update' do
    let(:dm_data) { fake_delivery_method_attrs('id' => '40') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('deliveryMethodUpdate' => dm_data)
    end

    it { expect(resource.update('40', name: 'Updated')).to be_a(Printavo::DeliveryMethod) }
  end

  describe '#archive' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::ARCHIVE_MUTATION, variables: { id: '40' })
        .and_return('deliveryMethodArchive' => { 'id' => '40' })
    end

    it { expect(resource.archive('40')).to be_nil }
  end
end
