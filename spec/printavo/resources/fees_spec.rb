# spec/printavo/resources/fees_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Fees do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:fee_data) { fake_fee_attrs }
    let(:response_data) do
      { 'order' => { 'fees' => {
        'nodes' => [fee_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { orderId: '99', first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all(order_id: '99')).to all(be_a(Printavo::Fee)) }
  end

  describe '#find' do
    let(:fee_data) { fake_fee_attrs('id' => '30') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '30' })
        .and_return('fee' => fee_data)
    end

    it { expect(resource.find('30')).to be_a(Printavo::Fee) }
    it { expect(resource.find('30').id).to eq('30') }
  end

  describe '#create' do
    let(:fee_data) { fake_fee_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('feeCreate' => fee_data)
    end

    it { expect(resource.create(name: 'Setup Fee', amount: '25.00')).to be_a(Printavo::Fee) }
  end

  describe '#creates' do
    let(:fees_data) { [fake_fee_attrs, fake_fee_attrs] }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATES_MUTATION, variables: anything)
        .and_return('feeCreates' => fees_data)
    end

    it { expect(resource.creates([{ name: 'A' }, { name: 'B' }])).to all(be_a(Printavo::Fee)) }
  end

  describe '#update' do
    let(:fee_data) { fake_fee_attrs('id' => '30') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('feeUpdate' => fee_data)
    end

    it { expect(resource.update('30', amount: '30.00')).to be_a(Printavo::Fee) }
  end

  describe '#updates' do
    let(:fees_data) { [fake_fee_attrs, fake_fee_attrs] }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATES_MUTATION, variables: anything)
        .and_return('feeUpdates' => fees_data)
    end

    it { expect(resource.updates([{ id: '1', amount: '35.00' }])).to all(be_a(Printavo::Fee)) }
  end

  describe '#delete' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETE_MUTATION, variables: { id: '30' })
        .and_return('feeDelete' => { 'id' => '30' })
    end

    it { expect(resource.delete('30')).to be_nil }
  end

  describe '#deletes' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETES_MUTATION, variables: { ids: %w[1 2] })
        .and_return('feeDeletes' => [{ 'id' => '1' }, { 'id' => '2' }])
    end

    it { expect(resource.deletes([1, 2])).to be_nil }
  end
end
