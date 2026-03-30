# spec/printavo/resources/statuses_spec.rb
require 'spec_helper'

RSpec.describe Printavo::Resources::Statuses do
  subject(:resource) { described_class.new(graphql) }

  let(:graphql) { instance_spy(Printavo::GraphqlClient) }

  let(:in_production_attrs) { { 'id' => '1', 'name' => 'In Production', 'color' => '#ff6600' } }
  let(:new_inquiry_attrs)   { { 'id' => '2', 'name' => 'New Inquiry', 'color' => '#3399ff' } }
  let(:completed_attrs)     { { 'id' => '3', 'name' => 'Completed', 'color' => '#00cc44' } }
  let(:all_nodes)           { [in_production_attrs, new_inquiry_attrs, completed_attrs] }
  let(:page_info)           { { 'hasNextPage' => false, 'endCursor' => nil } }

  describe '#all' do
    before do
      allow(graphql).to receive(:query).and_return(
        'statuses' => { 'nodes' => all_nodes, 'pageInfo' => page_info }
      )
    end

    it 'returns an array of Status objects' do
      expect(resource.all).to all(be_a(Printavo::Status))
    end

    it 'returns the correct count' do
      expect(resource.all.size).to eq(3)
    end

    it 'maps name correctly' do
      expect(resource.all.first.name).to eq('In Production')
    end

    it 'maps color correctly' do
      expect(resource.all.first.color).to eq('#ff6600')
    end

    it 'passes first: 100 by default' do
      allow(graphql).to receive(:query)
        .with(anything, variables: { first: 100, after: nil })
        .and_return('statuses' => { 'nodes' => [], 'pageInfo' => page_info })
      resource.all
      expect(graphql).to have_received(:query)
        .with(anything, variables: { first: 100, after: nil })
    end

    it 'forwards pagination arguments' do
      allow(graphql).to receive(:query)
        .with(anything, variables: { first: 50, after: 'cursor123' })
        .and_return('statuses' => { 'nodes' => [], 'pageInfo' => page_info })
      resource.all(first: 50, after: 'cursor123')
      expect(graphql).to have_received(:query)
        .with(anything, variables: { first: 50, after: 'cursor123' })
    end
  end

  describe '#each_page / #all_pages' do
    before do
      allow(graphql).to receive(:query).and_return(
        'statuses' => { 'nodes' => all_nodes, 'pageInfo' => page_info }
      )
    end

    it 'each_page yields arrays of Status objects' do
      pages = []
      resource.each_page { |records| pages << records }
      expect(pages.flatten).to all(be_a(Printavo::Status))
    end

    it 'all_pages returns a flat array of Statuses' do
      expect(resource.all_pages).to all(be_a(Printavo::Status))
    end
  end

  describe '#find' do
    before do
      allow(graphql).to receive(:query).and_return('status' => in_production_attrs)
    end

    it 'returns a single Status' do
      expect(resource.find('1')).to be_a(Printavo::Status)
    end

    it 'maps attributes correctly' do
      status = resource.find('1')
      expect(status.id).to eq('1')
      expect(status.name).to eq('In Production')
      expect(status.color).to eq('#ff6600')
    end

    it 'coerces the id to a string' do
      allow(graphql).to receive(:query)
        .with(anything, variables: { id: '1' })
        .and_return('status' => in_production_attrs)
      resource.find(1)
      expect(graphql).to have_received(:query)
        .with(anything, variables: { id: '1' })
    end
  end

  describe '#registry' do
    before do
      allow(graphql).to receive(:query).and_return(
        'statuses' => { 'nodes' => all_nodes, 'pageInfo' => page_info }
      )
    end

    it 'returns a Hash' do
      expect(resource.registry).to be_a(Hash)
    end

    it 'keys statuses by their symbol key' do
      expect(resource.registry.keys).to contain_exactly(:in_production, :new_inquiry, :completed)
    end

    it 'values are Status instances' do
      expect(resource.registry.values).to all(be_a(Printavo::Status))
    end

    it 'allows O(1) lookup by key' do
      status = resource.registry[:in_production]
      expect(status.name).to eq('In Production')
      expect(status.color).to eq('#ff6600')
    end

    it 'pairs with Order#status_key' do
      order = Printavo::Order.new(
        'id' => '1', 'nickname' => 'Test',
        'status' => { 'id' => '1', 'name' => 'In Production', 'color' => '#ff6600' }
      )
      registry = resource.registry
      expect(registry[order.status_key]).to be_a(Printavo::Status)
      expect(registry[order.status_key].name).to eq('In Production')
    end
  end
end
