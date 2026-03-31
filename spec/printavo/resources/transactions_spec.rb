# spec/printavo/resources/transactions_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Transactions do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:transaction_data) { fake_transaction_attrs }
    let(:response_data) do
      {
        'order' => {
          'transactions' => {
            'nodes' => [transaction_data],
            'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
          }
        }
      }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { orderId: '99', first: 25, after: nil })
        .and_return(response_data)
    end

    it 'returns an array of Transaction models' do
      expect(resource.all(order_id: '99')).to all(be_a(Printavo::Transaction))
    end

    it 'maps attributes correctly' do
      tx = resource.all(order_id: '99').first
      expect(tx.id).to     eq(transaction_data['id'])
      expect(tx.amount).to eq(transaction_data['amount'])
      expect(tx.kind).to   eq(transaction_data['kind'])
    end
  end

  describe '#find' do
    let(:transaction_data) { fake_transaction_attrs('id' => '55') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '55' })
        .and_return('transaction' => transaction_data)
    end

    it { expect(resource.find('55')).to be_a(Printavo::Transaction) }
    it { expect(resource.find('55').id).to eq('55') }
  end
end
