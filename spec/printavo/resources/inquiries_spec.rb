# spec/printavo/resources/inquiries_spec.rb
require 'spec_helper'

RSpec.describe Printavo::Resources::Inquiries do
  subject(:resource) { described_class.new(graphql) }

  let(:graphql)   { instance_spy(Printavo::GraphqlClient) }
  let(:page_info) { { 'hasNextPage' => false, 'endCursor' => nil } }

  let(:inquiry_attrs) do
    {
      'id' => '55',
      'nickname' => 'Summer22',
      'totalPrice' => '350.00',
      'status' => { 'id' => '2', 'name' => 'New Inquiry', 'color' => '#3399ff' },
      'customer' => {
        'id' => '10',
        'firstName' => 'Jane',
        'lastName' => 'Smith',
        'email' => 'jane@example.com',
        'company' => 'Acme Shirts'
      }
    }
  end

  describe '#all' do
    before do
      allow(graphql).to receive(:query).and_return(
        'inquiries' => { 'nodes' => [inquiry_attrs], 'pageInfo' => page_info }
      )
    end

    it 'returns an array of Inquiry objects' do
      expect(resource.all).to all(be_a(Printavo::Inquiry))
    end

    it 'returns the correct count' do
      expect(resource.all.size).to eq(1)
    end

    it 'maps nickname correctly' do
      expect(resource.all.first.nickname).to eq('Summer22')
    end

    it 'passes first: 25 by default' do
      allow(graphql).to receive(:query)
        .with(anything, variables: { first: 25, after: nil })
        .and_return('inquiries' => { 'nodes' => [], 'pageInfo' => page_info })
      resource.all
      expect(graphql).to have_received(:query)
        .with(anything, variables: { first: 25, after: nil })
    end

    it 'forwards pagination arguments' do
      allow(graphql).to receive(:query)
        .with(anything, variables: { first: 10, after: 'cur' })
        .and_return('inquiries' => { 'nodes' => [], 'pageInfo' => page_info })
      resource.all(first: 10, after: 'cur')
      expect(graphql).to have_received(:query)
        .with(anything, variables: { first: 10, after: 'cur' })
    end
  end

  describe '#find' do
    before do
      allow(graphql).to receive(:query).and_return('inquiry' => inquiry_attrs)
    end

    it 'returns a single Inquiry' do
      expect(resource.find('55')).to be_a(Printavo::Inquiry)
    end

    it 'maps id correctly' do
      expect(resource.find('55').id).to eq('55')
    end

    it 'maps status correctly' do
      expect(resource.find('55').status).to eq('New Inquiry')
    end

    it 'maps customer correctly' do
      customer = resource.find('55').customer
      expect(customer).to be_a(Printavo::Customer)
      expect(customer.full_name).to eq('Jane Smith')
    end

    it 'coerces the id to a string' do
      allow(graphql).to receive(:query)
        .with(anything, variables: { id: '55' })
        .and_return('inquiry' => inquiry_attrs)
      resource.find(55)
      expect(graphql).to have_received(:query)
        .with(anything, variables: { id: '55' })
    end
  end
end
