# spec/printavo/transaction_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Transaction do
  subject(:transaction) { described_class.new(fake_transaction_attrs) }

  it { expect(transaction.id).to be_a(String) }
  it { expect(transaction.amount).to be_a(String) }
  it { expect(transaction.kind).to be_a(String) }
  it { expect(transaction.created_at).to be_a(String) }

  context 'with current transaction fields' do
    subject(:transaction) do
      described_class.new(
        'amount' => 125.0,
        'category' => 'CREDIT_CARD',
        'description' => 'Deposit',
        'processing' => true,
        'transactionDate' => '2026-09-29',
        'timestamps' => { 'createdAt' => '2026-09-29T10:00:00Z', 'updatedAt' => '2026-09-29T11:00:00Z' }
      )
    end

    it { expect(transaction.category).to eq('CREDIT_CARD') }
    it { expect(transaction.description).to eq('Deposit') }
    it { expect(transaction).to be_processing }
    it { expect(transaction.transaction_date).to eq('2026-09-29') }
    it { expect(transaction.created_at).to eq('2026-09-29T10:00:00Z') }
    it { expect(transaction.updated_at).to eq('2026-09-29T11:00:00Z') }
  end

  describe 'ledger subclasses' do
    let(:attributes) { { 'id' => '1', 'amount' => 25.0, 'status' => 'WON' } }

    it { expect(Printavo::PaymentDispute.new(attributes).status).to eq('WON') }
    it { expect(Printavo::Refund.new(attributes)).to be_a(described_class) }
    it { expect(Printavo::Return.new(attributes)).to be_a(described_class) }
    it { expect(Printavo::Void.new(attributes)).to be_a(described_class) }
  end
end
