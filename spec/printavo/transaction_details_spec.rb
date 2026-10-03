# spec/printavo/transaction_details_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::TransactionDetails do
  subject(:details) do
    described_class.new('id' => '9', 'amount' => 42.5, 'category' => 'PAYMENT',
                        'ccCardType' => 'Visa', 'ccLastFour' => '4242',
                        'description' => 'Deposit', 'portalTransactionId' => 'portal-9',
                        'processing' => false, 'transactionDate' => '2026-09-29')
  end

  it 'exposes the transaction identity and amount' do
    expect(details.id).to eq('9')
    expect(details.amount).to eq(42.5)
    expect(details.category).to eq('PAYMENT')
  end

  it 'exposes sanitized card and provider references' do
    expect(details.card_type).to eq('Visa')
    expect(details.card_last_four).to eq('4242')
    expect(details.description).to eq('Deposit')
    expect(details.portal_transaction_id).to eq('portal-9')
  end

  it 'exposes processing state and transaction date' do
    expect(details).not_to be_processing
    expect(details.transaction_date).to eq('2026-09-29')
  end
end
