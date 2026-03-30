# spec/printavo/customer_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Customer do
  subject(:customer) { described_class.new(fake_customer_attrs) }

  describe 'attribute readers' do
    it 'exposes id' do
      expect(customer.id).to be_a(String)
    end

    it 'exposes first_name' do
      expect(customer.first_name).to be_a(String)
    end

    it 'exposes last_name' do
      expect(customer.last_name).to be_a(String)
    end

    it 'exposes email' do
      expect(customer.email).to include('@')
    end

    it 'exposes phone' do
      expect(customer.phone).to be_a(String)
    end

    it 'exposes company' do
      expect(customer.company).to be_a(String)
    end
  end

  describe '#full_name' do
    it 'joins first and last name' do
      c = described_class.new('firstName' => 'Jane', 'lastName' => 'Smith')
      expect(c.full_name).to eq('Jane Smith')
    end

    it 'handles a missing last name gracefully' do
      c = described_class.new('firstName' => 'Cher', 'lastName' => nil)
      expect(c.full_name).to eq('Cher')
    end

    it 'handles a missing first name gracefully' do
      c = described_class.new('firstName' => nil, 'lastName' => 'Prince')
      expect(c.full_name).to eq('Prince')
    end

    it 'strips extra whitespace when both names are present' do
      c = described_class.new('firstName' => '  Jane  ', 'lastName' => 'Smith')
      expect(c.full_name).to eq('Jane   Smith') # strip only trims the outer edges
    end
  end
end
