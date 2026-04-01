# spec/printavo/resources/orders_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Orders do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:order_data) { fake_order_attrs }
    let(:response_data) do
      {
        'orders' => {
          'nodes' => [order_data],
          'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
        }
      }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it 'returns an array of Order models' do
      result = resource.all
      expect(result).to all(be_a(Printavo::Order))
    end

    it 'maps status correctly' do
      order = resource.all.first
      expect(order.status).to        eq('In Production')
      expect(order.status_key).to    eq(:in_production)
      expect(order.status_id).to     eq('1')
      expect(order.status_color).to  eq('#ff6600')
    end

    it 'exposes an associated customer' do
      order = resource.all.first
      expect(order.customer).to be_a(Printavo::Customer)
    end
  end

  describe '#each_page / #all_pages' do
    let(:page_response) do
      {
        'orders' => {
          'nodes' => [fake_order_attrs],
          'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
        }
      }
    end

    before { allow(graphql).to receive(:query).and_return(page_response) }

    it 'each_page yields arrays of Order objects' do
      pages = []
      resource.each_page { |records| pages << records }
      expect(pages.flatten).to all(be_a(Printavo::Order))
    end

    it 'all_pages returns a flat array of Orders' do
      expect(resource.all_pages).to all(be_a(Printavo::Order))
    end
  end

  describe '#create' do
    let(:mutation_response) { fake_order_mutation_response }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('quoteCreate' => mutation_response)
    end

    it 'returns an Order' do
      result = resource.create(contact: { id: '10' }, due_at: '2026-06-01T09:00:00Z',
                               customer_due_at: '2026-06-01')
      expect(result).to be_a(Printavo::Order)
    end

    it 'normalizes total to totalPrice' do
      order = resource.create(contact: { id: '10' }, due_at: '2026-06-01T09:00:00Z',
                              customer_due_at: '2026-06-01')
      expect(order.total_price).to eq(mutation_response['total'])
    end

    it 'camelizes snake_case input keys' do
      allow(graphql).to receive(:mutate)
        .with(anything, variables: { input: hash_including('customerDueAt' => '2026-06-01') })
        .and_return('quoteCreate' => mutation_response)
      resource.create(contact: { id: '10' }, due_at: '2026-06-01T09:00:00Z',
                      customer_due_at: '2026-06-01')
      expect(graphql).to have_received(:mutate)
        .with(anything, variables: { input: hash_including('customerDueAt' => '2026-06-01') })
    end
  end

  describe '#update' do
    let(:mutation_response) { fake_order_mutation_response('id' => '99') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('quoteUpdate' => mutation_response)
    end

    it 'returns an Order' do
      expect(resource.update('99', nickname: 'Rush Job')).to be_a(Printavo::Order)
    end

    it 'passes the id as a string' do
      allow(graphql).to receive(:mutate)
        .with(anything, variables: hash_including(id: '99'))
        .and_return('quoteUpdate' => mutation_response)
      resource.update(99, nickname: 'Rush Job')
      expect(graphql).to have_received(:mutate)
        .with(anything, variables: hash_including(id: '99'))
    end

    it 'camelizes snake_case input keys' do
      allow(graphql).to receive(:mutate)
        .with(anything, variables: { id: '99', input: hash_including('productionNote' => 'Ships Friday') })
        .and_return('quoteUpdate' => mutation_response)
      resource.update('99', production_note: 'Ships Friday')
      expect(graphql).to have_received(:mutate)
        .with(anything, variables: { id: '99', input: hash_including('productionNote' => 'Ships Friday') })
    end
  end

  describe '#update_status' do
    let(:mutation_response) { fake_order_mutation_response('id' => '99') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_STATUS_MUTATION, variables: anything)
        .and_return('statusUpdate' => mutation_response)
    end

    it 'returns an Order' do
      expect(resource.update_status('99', status_id: '3')).to be_a(Printavo::Order)
    end

    it 'normalizes total to totalPrice' do
      order = resource.update_status('99', status_id: '3')
      expect(order.total_price).to eq(mutation_response['total'])
    end

    it 'passes parentId and statusId as strings' do
      allow(graphql).to receive(:mutate)
        .with(anything, variables: { parentId: '99', statusId: '3' })
        .and_return('statusUpdate' => mutation_response)
      resource.update_status(99, status_id: 3)
      expect(graphql).to have_received(:mutate)
        .with(anything, variables: { parentId: '99', statusId: '3' })
    end
  end

  describe '#find' do
    let(:order_data)    { fake_order_attrs('id' => '99') }
    let(:response_data) { { 'order' => order_data } }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '99' })
        .and_return(response_data)
    end

    it 'returns a single Order model' do
      order = resource.find('99')
      expect(order).to be_a(Printavo::Order)
      expect(order.id).to eq('99')
    end

    it 'supports status? predicate' do
      order = resource.find('99')
      expect(order.status?(:in_production)).to be true
      expect(order.status?(:completed)).to     be false
    end
  end

  describe '#delete' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETE_MUTATION, variables: { id: '99' })
        .and_return('quoteDelete' => { 'id' => '99' })
    end

    it { expect(resource.delete('99')).to be_nil }
  end

  describe '#duplicate' do
    let(:mutation_response) { fake_order_mutation_response('id' => '200') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DUPLICATE_MUTATION, variables: { id: '99' })
        .and_return('quoteDuplicate' => mutation_response)
    end

    it 'returns a new Order' do
      expect(resource.duplicate('99')).to be_a(Printavo::Order)
    end

    it 'maps the new order id' do
      expect(resource.duplicate('99').id).to eq('200')
    end

    it 'normalizes total to totalPrice' do
      order = resource.duplicate('99')
      expect(order.total_price).to eq(mutation_response['total'])
    end
  end
end
