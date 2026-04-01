# spec/printavo/resources/production_files_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::ProductionFiles do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:file_data) { fake_production_file_attrs }
    let(:response_data) do
      { 'order' => { 'productionFiles' => {
        'nodes' => [file_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { orderId: '99', first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all(order_id: '99')).to all(be_a(Printavo::ProductionFile)) }
  end

  describe '#find' do
    let(:file_data) { fake_production_file_attrs('id' => '10') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '10' })
        .and_return('productionFile' => file_data)
    end

    it { expect(resource.find('10')).to be_a(Printavo::ProductionFile) }
    it { expect(resource.find('10').id).to eq('10') }
  end

  describe '#create' do
    let(:file_data) { fake_production_file_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('productionFileCreate' => file_data)
    end

    it { expect(resource.create(order_id: '99', url: 'https://example.com/file.pdf')).to be_a(Printavo::ProductionFile) }
  end

  describe '#creates' do
    let(:files_data) { [fake_production_file_attrs, fake_production_file_attrs] }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATES_MUTATION, variables: anything)
        .and_return('productionFileCreates' => files_data)
    end

    it { expect(resource.creates([{ order_id: '99' }, { order_id: '99' }])).to all(be_a(Printavo::ProductionFile)) }
  end

  describe '#delete' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETE_MUTATION, variables: { id: '10' })
        .and_return('productionFileDelete' => { 'id' => '10' })
    end

    it { expect(resource.delete('10')).to be_nil }
  end

  describe '#deletes' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETES_MUTATION, variables: { ids: %w[1 2] })
        .and_return('productionFileDeletes' => [{ 'id' => '1' }, { 'id' => '2' }])
    end

    it { expect(resource.deletes([1, 2])).to be_nil }
  end
end
