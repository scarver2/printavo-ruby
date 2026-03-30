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

  describe '#customers' do
    it 'returns a Customers resource' do
      expect(client.customers).to be_a(Printavo::Resources::Customers)
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
end
