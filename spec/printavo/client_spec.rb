# spec/printavo/client_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Client do
  subject(:client) { described_class.new(email: PRINTAVO_TEST_EMAIL, token: PRINTAVO_TEST_TOKEN) }

  describe '#initialize' do
    it 'creates a client with email and token' do
      expect(client).to be_a(described_class)
    end

    it 'exposes a graphql interface' do
      expect(client.graphql).to be_a(Printavo::GraphqlClient)
    end

    it 'supports multiple independent instances' do
      client_a = described_class.new(email: 'a@example.com', token: 'token_a')
      client_b = described_class.new(email: 'b@example.com', token: 'token_b')
      expect(client_a).not_to equal(client_b)
    end
  end

  describe '#account' do
    it 'returns an Account resource' do
      expect(client.account).to be_a(Printavo::Resources::Account)
    end
  end

  describe '#contacts' do
    it 'returns a Contacts resource' do
      expect(client.contacts).to be_a(Printavo::Resources::Contacts)
    end
  end

  describe '#customers' do
    it 'returns a Customers resource' do
      expect(client.customers).to be_a(Printavo::Resources::Customers)
    end
  end

  describe '#invoices' do
    it 'returns an Invoices resource' do
      expect(client.invoices).to be_a(Printavo::Resources::Invoices)
    end
  end

  describe '#statuses' do
    it 'returns a Statuses resource' do
      expect(client.statuses).to be_a(Printavo::Resources::Statuses)
    end
  end

  describe '#orders' do
    it 'returns an Orders resource' do
      expect(client.orders).to be_a(Printavo::Resources::Orders)
    end
  end

  describe '#jobs' do
    it 'returns a Jobs resource' do
      expect(client.jobs).to be_a(Printavo::Resources::Jobs)
    end
  end

  describe '#inquiries' do
    it 'returns an Inquiries resource' do
      expect(client.inquiries).to be_a(Printavo::Resources::Inquiries)
    end
  end

  describe '#tasks' do
    it 'returns a Tasks resource' do
      expect(client.tasks).to be_a(Printavo::Resources::Tasks)
    end
  end

  describe '#threads' do
    it 'returns a Threads resource' do
      expect(client.threads).to be_a(Printavo::Resources::Threads)
    end
  end

  describe '#transactions' do
    it 'returns a Transactions resource' do
      expect(client.transactions).to be_a(Printavo::Resources::Transactions)
    end
  end

  describe '#transaction_payments' do
    it 'returns a TransactionPayments resource' do
      expect(client.transaction_payments).to be_a(Printavo::Resources::TransactionPayments)
    end
  end

  describe '#login' do
    it 'raises NotImplementedError' do
      expect { client.login }.to raise_error(NotImplementedError, /email \+ token/)
    end
  end

  describe '#logout' do
    it 'raises NotImplementedError' do
      expect { client.logout }.to raise_error(NotImplementedError, /stateless/)
    end
  end
end
