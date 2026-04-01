# spec/printavo/resources/invoices_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Invoices do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:invoice_data) { fake_invoice_attrs }
    let(:response_data) do
      {
        'invoices' => {
          'nodes' => [invoice_data],
          'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
        }
      }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it 'returns an array of Invoice models' do
      expect(resource.all).to all(be_a(Printavo::Invoice))
    end

    it 'maps attributes correctly' do
      invoice = resource.all.first
      expect(invoice.id).to       eq(invoice_data['id'])
      expect(invoice.nickname).to eq(invoice_data['nickname'])
      expect(invoice.total).to    eq(invoice_data['total'])
    end

    it 'supports pagination parameters' do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 10, after: 'abc' })
        .and_return(response_data)
      expect(resource.all(first: 10, after: 'abc')).to be_an(Array)
    end
  end

  describe '#each_page' do
    let(:page_one) do
      {
        'invoices' => {
          'nodes' => [fake_invoice_attrs, fake_invoice_attrs],
          'pageInfo' => { 'hasNextPage' => true, 'endCursor' => 'cur_1' }
        }
      }
    end
    let(:page_two) do
      {
        'invoices' => {
          'nodes' => [fake_invoice_attrs],
          'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
        }
      }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(page_one)
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: 'cur_1' })
        .and_return(page_two)
    end

    it 'yields Invoice objects across all pages' do
      pages = []
      resource.each_page { |records| pages << records }
      expect(pages.flatten).to all(be_a(Printavo::Invoice))
      expect(pages.map(&:size)).to eq([2, 1])
    end
  end

  describe '#find' do
    let(:invoice_data) { fake_invoice_attrs('id' => '456') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '456' })
        .and_return('invoice' => invoice_data)
    end

    it 'returns a single Invoice model' do
      expect(resource.find('456')).to be_a(Printavo::Invoice)
    end

    it 'maps the id correctly' do
      expect(resource.find('456').id).to eq('456')
    end
  end

  describe '#update' do
    let(:invoice_data) { fake_invoice_attrs('id' => '456') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('invoiceUpdate' => invoice_data)
    end

    it 'returns an Invoice' do
      expect(resource.update('456', nickname: 'Final Invoice')).to be_a(Printavo::Invoice)
    end

    it 'passes the id as a string' do
      allow(graphql).to receive(:mutate)
        .with(anything, variables: hash_including(id: '456'))
        .and_return('invoiceUpdate' => invoice_data)
      resource.update(456, nickname: 'Final Invoice')
      expect(graphql).to have_received(:mutate)
        .with(anything, variables: hash_including(id: '456'))
    end

    it 'camelizes snake_case input keys' do
      allow(graphql).to receive(:mutate)
        .with(anything, variables: { id: '456', input: hash_including('paymentDueAt' => '2026-05-01') })
        .and_return('invoiceUpdate' => invoice_data)
      resource.update('456', payment_due_at: '2026-05-01')
      expect(graphql).to have_received(:mutate)
        .with(anything, variables: { id: '456', input: hash_including('paymentDueAt' => '2026-05-01') })
    end
  end

  describe '#delete' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETE_MUTATION, variables: { id: '456' })
        .and_return('invoiceDelete' => { 'id' => '456' })
    end

    it { expect(resource.delete('456')).to be_nil }
  end

  describe '#duplicate' do
    let(:invoice_data) { fake_invoice_attrs('id' => '789') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DUPLICATE_MUTATION, variables: { id: '456' })
        .and_return('invoiceDuplicate' => invoice_data)
    end

    it 'returns a new Invoice' do
      expect(resource.duplicate('456')).to be_a(Printavo::Invoice)
    end

    it 'maps the new invoice id' do
      expect(resource.duplicate('456').id).to eq('789')
    end
  end
end
