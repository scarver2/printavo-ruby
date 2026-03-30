# spec/printavo/resources/customers_spec.rb
require 'spec_helper'

RSpec.describe Printavo::Resources::Customers do
  let(:graphql) { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:customer_data) { fake_customer_attrs }
    let(:response_data) do
      {
        'customers' => {
          'nodes' => [customer_data],
          'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
        }
      }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it 'returns an array of Customer models' do
      result = resource.all
      expect(result).to all(be_a(Printavo::Customer))
    end

    it 'maps attributes correctly' do
      customer = resource.all.first
      expect(customer.id).to         eq(customer_data['id'])
      expect(customer.first_name).to eq(customer_data['firstName'])
      expect(customer.email).to      eq(customer_data['email'])
    end

    it 'supports pagination parameters' do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 10, after: 'cursor123' })
        .and_return(response_data)

      result = resource.all(first: 10, after: 'cursor123')
      expect(result).to be_an(Array)
    end
  end

  describe '#each_page' do
    let(:page_one) do
      {
        'customers' => {
          'nodes' => [fake_customer_attrs, fake_customer_attrs],
          'pageInfo' => { 'hasNextPage' => true, 'endCursor' => 'cursor_1' }
        }
      }
    end
    let(:page_two) do
      {
        'customers' => {
          'nodes' => [fake_customer_attrs],
          'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
        }
      }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(page_one)
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: 'cursor_1' })
        .and_return(page_two)
    end

    it 'yields each page of Customer objects' do
      pages = []
      resource.each_page { |records| pages << records }
      expect(pages.size).to eq(2)
      expect(pages.flatten).to all(be_a(Printavo::Customer))
    end

    it 'yields page one then page two in order' do
      sizes = []
      resource.each_page { |records| sizes << records.size }
      expect(sizes).to eq([2, 1])
    end

    it 'stops after the last page' do
      call_count = 0
      resource.each_page { call_count += 1 }
      expect(call_count).to eq(2)
    end
  end

  describe '#all_pages' do
    let(:page_one) do
      {
        'customers' => {
          'nodes' => [fake_customer_attrs, fake_customer_attrs],
          'pageInfo' => { 'hasNextPage' => true, 'endCursor' => 'cursor_1' }
        }
      }
    end
    let(:page_two) do
      {
        'customers' => {
          'nodes' => [fake_customer_attrs],
          'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
        }
      }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(page_one)
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: 'cursor_1' })
        .and_return(page_two)
    end

    it 'returns all records as a flat array' do
      result = resource.all_pages
      expect(result.size).to eq(3)
      expect(result).to all(be_a(Printavo::Customer))
    end
  end

  describe '#create' do
    let(:mutation_response) { fake_customer_mutation_response }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('customerCreate' => mutation_response)
    end

    it 'returns a Customer' do
      result = resource.create(primary_contact: { firstName: 'Jane', email: 'jane@example.com' })
      expect(result).to be_a(Printavo::Customer)
    end

    it 'normalizes primaryContact into top-level model fields' do
      customer = resource.create(primary_contact: { firstName: 'Jane', email: 'jane@example.com' })
      expect(customer.first_name).to eq(mutation_response['primaryContact']['firstName'])
      expect(customer.email).to eq(mutation_response['primaryContact']['email'])
    end

    it 'normalizes companyName to company' do
      customer = resource.create(primary_contact: { firstName: 'Jane', email: 'jane@example.com' })
      expect(customer.company).to eq(mutation_response['companyName'])
    end

    it 'camelizes snake_case input keys' do
      allow(graphql).to receive(:mutate)
        .with(anything, variables: { input: hash_including('companyName' => 'Acme') })
        .and_return('customerCreate' => mutation_response)
      resource.create(primary_contact: { firstName: 'Jane', email: 'jane@example.com' },
                      company_name: 'Acme')
      expect(graphql).to have_received(:mutate)
        .with(anything, variables: { input: hash_including('companyName' => 'Acme') })
    end
  end

  describe '#update' do
    let(:mutation_response) { fake_customer_mutation_response('id' => '42') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('customerUpdate' => mutation_response)
    end

    it 'returns a Customer' do
      expect(resource.update('42', company_name: 'New Co')).to be_a(Printavo::Customer)
    end

    it 'passes the id as a string' do
      allow(graphql).to receive(:mutate)
        .with(anything, variables: hash_including(id: '42'))
        .and_return('customerUpdate' => mutation_response)
      resource.update(42, company_name: 'New Co')
      expect(graphql).to have_received(:mutate)
        .with(anything, variables: hash_including(id: '42'))
    end

    it 'camelizes snake_case input keys' do
      allow(graphql).to receive(:mutate)
        .with(anything, variables: { id: '42', input: hash_including('companyName' => 'New Co') })
        .and_return('customerUpdate' => mutation_response)
      resource.update('42', company_name: 'New Co')
      expect(graphql).to have_received(:mutate)
        .with(anything, variables: { id: '42', input: hash_including('companyName' => 'New Co') })
    end
  end

  describe '#find' do
    let(:customer_data) { fake_customer_attrs('id' => '42') }
    let(:response_data) { { 'customer' => customer_data } }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '42' })
        .and_return(response_data)
    end

    it 'returns a single Customer model' do
      customer = resource.find('42')
      expect(customer).to be_a(Printavo::Customer)
    end

    it 'maps the id correctly' do
      customer = resource.find('42')
      expect(customer.id).to eq('42')
    end
  end
end
