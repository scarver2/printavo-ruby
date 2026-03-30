# spec/printavo/inquiry_spec.rb
require 'spec_helper'

RSpec.describe Printavo::Inquiry do
  subject(:inquiry) { described_class.new(attrs) }

  let(:customer_attrs) do
    { 'id' => '10', 'firstName' => 'Jane', 'lastName' => 'Smith',
      'email' => 'jane@example.com', 'company' => 'Acme Shirts' }
  end

  let(:attrs) do
    {
      'id' => '99',
      'nickname' => 'Summer22',
      'totalPrice' => '350.00',
      'status' => { 'id' => '2', 'name' => 'New Inquiry', 'color' => '#3399ff' },
      'customer' => customer_attrs
    }
  end

  describe '#id' do
    it('returns id') { expect(inquiry.id).to eq('99') }
  end

  describe '#nickname' do
    it('returns nickname') { expect(inquiry.nickname).to eq('Summer22') }
  end

  describe '#total_price' do
    it('returns totalPrice') { expect(inquiry.total_price).to eq('350.00') }
  end

  describe '#status' do
    it 'returns the status name' do
      expect(inquiry.status).to eq('New Inquiry')
    end

    it 'returns nil when status is absent' do
      expect(described_class.new('id' => '1').status).to be_nil
    end
  end

  describe '#status_key' do
    it 'returns a snake_case symbol' do
      expect(inquiry.status_key).to eq(:new_inquiry)
    end

    it 'returns nil when status is nil' do
      expect(described_class.new('id' => '1').status_key).to be_nil
    end
  end

  describe '#status?' do
    it 'returns true for a matching symbol' do
      expect(inquiry.status?(:new_inquiry)).to be true
    end

    it 'returns false for a non-matching symbol' do
      expect(inquiry.status?(:in_production)).to be false
    end

    it 'accepts a string key' do
      expect(inquiry.status?('new_inquiry')).to be true
    end
  end

  describe '#customer' do
    it 'returns a Customer instance' do
      expect(inquiry.customer).to be_a(Printavo::Customer)
    end

    it 'exposes customer attributes' do
      expect(inquiry.customer.full_name).to eq('Jane Smith')
    end

    it 'returns nil when customer data is absent' do
      expect(described_class.new('id' => '1').customer).to be_nil
    end
  end
end
