# spec/printavo/resources/orders_spec.rb
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
end
