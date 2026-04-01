# spec/printavo/invoice_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Invoice do
  subject(:invoice) { described_class.new(fake_invoice_attrs) }

  it { expect(invoice.id).to be_a(String) }
  it { expect(invoice.visual_id).to be_a(String) }
  it { expect(invoice.nickname).to be_a(String) }
  it { expect(invoice.created_at).to be_a(String) }
  it { expect(invoice.updated_at).to be_a(String) }
  it { expect(invoice.total).to be_a(String) }
  it { expect(invoice.amount_paid).to be_a(String) }
  it { expect(invoice.amount_outstanding).to be_a(String) }
  it { expect(invoice.paid_in_full?).to be(false) }
  it { expect(invoice.invoice_at).to be_a(String) }
  it { expect(invoice.payment_due_at).to be_a(String) }

  describe '#status' do
    it { expect(invoice.status).to eq('Invoice') }
    it { expect(invoice.status_id).to be_a(String) }
    it { expect(invoice.status_color).to eq('#009900') }
    it { expect(invoice.status_key).to eq(:invoice) }
    it { expect(invoice.status?(:invoice)).to be true }
    it { expect(invoice.status?(:in_production)).to be false }
  end

  describe '#contact' do
    it 'returns a Contact instance' do
      expect(invoice.contact).to be_a(Printavo::Contact)
    end

    it 'returns nil when contact is absent' do
      i = described_class.new(fake_invoice_attrs('contact' => nil))
      expect(i.contact).to be_nil
    end
  end
end
