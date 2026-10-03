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

    context 'with transaction union members' do
      let(:response_data) do
        {
          'order' => {
            'transactions' => {
              'nodes' => %w[Payment PaymentDispute Refund Return Void].map do |type|
                fake_transaction_attrs('__typename' => type)
              end,
              'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
            }
          }
        }
      end

      it 'returns the concrete ledger model for each union member' do
        expect(resource.all(order_id: '99').map(&:class)).to eq(
          [Printavo::Payment, Printavo::PaymentDispute, Printavo::Refund, Printavo::Return, Printavo::Void]
        )
      end
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

    context 'when the transaction is a refund' do
      let(:transaction_data) { fake_transaction_attrs('id' => '55', '__typename' => 'Refund') }

      it { expect(resource.find('55')).to be_a(Printavo::Refund) }
    end
  end
end
