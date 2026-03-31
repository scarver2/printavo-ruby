# spec/printavo/resources/line_item_groups_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::LineItemGroups do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:group_data) { fake_line_item_group_attrs }
    let(:response_data) do
      { 'order' => { 'lineItemGroups' => {
        'nodes' => [group_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { orderId: '99', first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all(order_id: '99')).to all(be_a(Printavo::LineItemGroup)) }
  end

  describe '#find' do
    let(:group_data) { fake_line_item_group_attrs('id' => '10') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '10' })
        .and_return('lineItemGroup' => group_data)
    end

    it { expect(resource.find('10')).to be_a(Printavo::LineItemGroup) }
    it { expect(resource.find('10').id).to eq('10') }
  end

  describe '#create' do
    let(:group_data) { fake_line_item_group_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('lineItemGroupCreate' => group_data)
    end

    it { expect(resource.create(name: 'Adults', order_id: '99')).to be_a(Printavo::LineItemGroup) }
  end

  describe '#creates' do
    let(:groups_data) { [fake_line_item_group_attrs, fake_line_item_group_attrs] }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATES_MUTATION, variables: anything)
        .and_return('lineItemGroupCreates' => groups_data)
    end

    it { expect(resource.creates([{ name: 'A' }, { name: 'B' }])).to all(be_a(Printavo::LineItemGroup)) }
  end

  describe '#update' do
    let(:group_data) { fake_line_item_group_attrs('id' => '10') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('lineItemGroupUpdate' => group_data)
    end

    it { expect(resource.update('10', name: 'Youth')).to be_a(Printavo::LineItemGroup) }
  end

  describe '#updates' do
    let(:groups_data) { [fake_line_item_group_attrs, fake_line_item_group_attrs] }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATES_MUTATION, variables: anything)
        .and_return('lineItemGroupUpdates' => groups_data)
    end

    it { expect(resource.updates([{ id: '1', name: 'Youth' }])).to all(be_a(Printavo::LineItemGroup)) }
  end

  describe '#delete' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETE_MUTATION, variables: { id: '10' })
        .and_return('lineItemGroupDelete' => { 'id' => '10' })
    end

    it { expect(resource.delete('10')).to be_nil }
  end

  describe '#deletes' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETES_MUTATION, variables: { ids: %w[1 2] })
        .and_return('lineItemGroupDeletes' => [{ 'id' => '1' }, { 'id' => '2' }])
    end

    it { expect(resource.deletes([1, 2])).to be_nil }
  end
end
