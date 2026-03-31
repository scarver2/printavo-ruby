# spec/printavo/resources/line_items_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::LineItems do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }
  let(:group_id) { '10' }

  describe '#all' do
    let(:item_data) { fake_line_item_attrs }
    let(:response_data) do
      { 'lineItemGroup' => { 'lineItems' => {
        'nodes' => [item_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { lineItemGroupId: group_id, first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all(line_item_group_id: group_id)).to all(be_a(Printavo::LineItem)) }
  end

  describe '#find' do
    let(:item_data) { fake_line_item_attrs('id' => '99') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '99' })
        .and_return('lineItem' => item_data)
    end

    it { expect(resource.find('99')).to be_a(Printavo::LineItem) }
    it { expect(resource.find('99').id).to eq('99') }
  end

  describe '#create' do
    let(:item_data) { fake_line_item_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('lineItemCreate' => item_data)
    end

    it { expect(resource.create(name: 'T-Shirt', quantity: 12, price: '15.00')).to be_a(Printavo::LineItem) }
  end

  describe '#creates' do
    let(:items_data) { [fake_line_item_attrs, fake_line_item_attrs] }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATES_MUTATION, variables: anything)
        .and_return('lineItemCreates' => items_data)
    end

    it { expect(resource.creates([{ name: 'A' }, { name: 'B' }])).to all(be_a(Printavo::LineItem)) }
  end

  describe '#update' do
    let(:item_data) { fake_line_item_attrs('id' => '99') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('lineItemUpdate' => item_data)
    end

    it { expect(resource.update('99', quantity: 24)).to be_a(Printavo::LineItem) }
  end

  describe '#updates' do
    let(:items_data) { [fake_line_item_attrs, fake_line_item_attrs] }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATES_MUTATION, variables: anything)
        .and_return('lineItemUpdates' => items_data)
    end

    it { expect(resource.updates([{ id: '1', quantity: 1 }])).to all(be_a(Printavo::LineItem)) }
  end

  describe '#delete' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETE_MUTATION, variables: { id: '99' })
        .and_return('lineItemDelete' => { 'id' => '99' })
    end

    it { expect(resource.delete('99')).to be_nil }
  end

  describe '#deletes' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETES_MUTATION, variables: { ids: %w[1 2] })
        .and_return('lineItemDeletes' => [{ 'id' => '1' }, { 'id' => '2' }])
    end

    it { expect(resource.deletes([1, 2])).to be_nil }
  end

  describe '#mockup_creates' do
    let(:mockups_data) { [{ 'id' => '5', 'url' => 'https://example.com/a.png', 'position' => 1 }] }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::MOCKUP_CREATES_MUTATION, variables: anything)
        .and_return('lineItemMockupCreates' => mockups_data)
    end

    it { expect(resource.mockup_creates([{ line_item_id: '99', url: 'https://example.com/a.png' }])).to eq(mockups_data) }
  end

  describe '#mockup_create' do
    let(:mockup_data) { { 'id' => '5', 'url' => 'https://example.com/mockup.png', 'position' => 1 } }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::MOCKUP_CREATE_MUTATION, variables: anything)
        .and_return('lineItemMockupCreate' => mockup_data)
    end

    it { expect(resource.mockup_create(line_item_id: '99', url: 'https://example.com/mockup.png')).to eq(mockup_data) }
  end
end
