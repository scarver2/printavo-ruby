# spec/printavo/merch_order_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::MerchOrder do
  subject(:order) { described_class.new(fake_merch_order_attrs) }

  it { expect(order.id).to be_a(String) }
  it { expect(order.status).to be_a(String) }
  it { expect(order.delivery).to be_a(Hash) }

  describe '#contact' do
    it 'returns a Contact instance' do
      expect(order.contact).to be_a(Printavo::Contact)
    end

    it 'returns nil when contact is absent' do
      o = described_class.new(fake_merch_order_attrs('contact' => nil))
      expect(o.contact).to be_nil
    end
  end
end
