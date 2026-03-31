# spec/printavo/resources/transaction_payments_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::TransactionPayments do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#create' do
    let(:payment_data) { fake_transaction_payment_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('transactionPaymentCreate' => payment_data)
    end

    it { expect(resource.create(amount: '100.00', payment_method: 'cash')).to be_a(Printavo::TransactionPayment) }
  end

  describe '#update' do
    let(:payment_data) { fake_transaction_payment_attrs('id' => '77') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('transactionPaymentUpdate' => payment_data)
    end

    it { expect(resource.update('77', amount: '200.00')).to be_a(Printavo::TransactionPayment) }

    it 'passes the id as a string' do
      allow(graphql).to receive(:mutate)
        .with(anything, variables: hash_including(id: '77'))
        .and_return('transactionPaymentUpdate' => payment_data)
      resource.update(77, amount: '200.00')
      expect(graphql).to have_received(:mutate)
        .with(anything, variables: hash_including(id: '77'))
    end
  end

  describe '#delete' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETE_MUTATION, variables: { id: '77' })
        .and_return('transactionPaymentDelete' => { 'id' => '77' })
    end

    it { expect(resource.delete('77')).to be_nil }
  end
end
