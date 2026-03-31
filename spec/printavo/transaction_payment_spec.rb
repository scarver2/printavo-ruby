# spec/printavo/transaction_payment_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::TransactionPayment do
  subject(:payment) { described_class.new(fake_transaction_payment_attrs) }

  it { expect(payment.id).to be_a(String) }
  it { expect(payment.amount).to be_a(String) }
  it { expect(payment.payment_method).to be_a(String) }
  it { expect(payment.paid_at).to be_a(String) }
  it { expect(payment.note).to be_nil }
end
