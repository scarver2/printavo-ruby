# spec/printavo/transaction_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Transaction do
  subject(:transaction) { described_class.new(fake_transaction_attrs) }

  it { expect(transaction.id).to be_a(String) }
  it { expect(transaction.amount).to be_a(String) }
  it { expect(transaction.kind).to be_a(String) }
  it { expect(transaction.created_at).to be_a(String) }
end
