# spec/printavo/resources/imprints_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Imprints do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }
  let(:group_id) { '10' }

  describe '#all' do
    let(:imprint_data) { fake_imprint_attrs }
    let(:response_data) do
      { 'lineItemGroup' => { 'imprints' => {
        'nodes' => [imprint_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { lineItemGroupId: group_id, first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all(line_item_group_id: group_id)).to all(be_a(Printavo::Imprint)) }
  end

  describe '#find' do
    let(:imprint_data) { fake_imprint_attrs('id' => '20') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '20' })
        .and_return('imprint' => imprint_data)
    end

    it { expect(resource.find('20')).to be_a(Printavo::Imprint) }
    it { expect(resource.find('20').id).to eq('20') }
  end

  describe '#create' do
    let(:imprint_data) { fake_imprint_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('imprintCreate' => imprint_data)
    end

    it { expect(resource.create(name: 'Front', position: 'front', colors: 2)).to be_a(Printavo::Imprint) }
  end

  describe '#creates' do
    let(:imprints_data) { [fake_imprint_attrs, fake_imprint_attrs] }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATES_MUTATION, variables: anything)
        .and_return('imprintCreates' => imprints_data)
    end

    it { expect(resource.creates([{ name: 'A' }, { name: 'B' }])).to all(be_a(Printavo::Imprint)) }
  end

  describe '#update' do
    let(:imprint_data) { fake_imprint_attrs('id' => '20') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('imprintUpdate' => imprint_data)
    end

    it { expect(resource.update('20', colors: 4)).to be_a(Printavo::Imprint) }
  end

  describe '#updates' do
    let(:imprints_data) { [fake_imprint_attrs, fake_imprint_attrs] }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATES_MUTATION, variables: anything)
        .and_return('imprintUpdates' => imprints_data)
    end

    it { expect(resource.updates([{ id: '1', colors: 3 }])).to all(be_a(Printavo::Imprint)) }
  end

  describe '#delete' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETE_MUTATION, variables: { id: '20' })
        .and_return('imprintDelete' => { 'id' => '20' })
    end

    it { expect(resource.delete('20')).to be_nil }
  end

  describe '#deletes' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETES_MUTATION, variables: { ids: %w[1 2] })
        .and_return('imprintDeletes' => [{ 'id' => '1' }, { 'id' => '2' }])
    end

    it { expect(resource.deletes([1, 2])).to be_nil }
  end

  describe '#mockup_create' do
    let(:mockup_data) { { 'id' => '7', 'url' => 'https://example.com/m.png', 'position' => 1 } }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::MOCKUP_CREATE_MUTATION, variables: anything)
        .and_return('imprintMockupCreate' => mockup_data)
    end

    it { expect(resource.mockup_create(imprint_id: '20', url: 'https://example.com/m.png')).to eq(mockup_data) }
  end

  describe '#mockup_creates' do
    let(:mockups_data) { [{ 'id' => '7', 'url' => 'https://example.com/a.png', 'position' => 1 }] }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::MOCKUP_CREATES_MUTATION, variables: anything)
        .and_return('imprintMockupCreates' => mockups_data)
    end

    it { expect(resource.mockup_creates([{ imprint_id: '20', url: 'https://example.com/a.png' }])).to eq(mockups_data) }
  end
end
