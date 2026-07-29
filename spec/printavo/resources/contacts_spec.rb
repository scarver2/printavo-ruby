# spec/printavo/resources/contacts_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Contacts do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#page' do
    let(:contact_data) { fake_contact_attrs('id' => '123') }
    let(:envelope) do
      Printavo::ResponseEnvelope.new(
        data: {
          'contacts' => {
            'nodes' => [contact_data],
            'pageInfo' => { 'hasNextPage' => true, 'endCursor' => 'cursor-1' }
          }
        },
        errors: [],
        metadata: { 'x-request-id' => 'request-1' }
      )
    end
    let(:all_filters) do
      {
        first: 50,
        after: 'previous-cursor',
        primary_only: false,
        query: 'Acme',
        sort_on: Printavo::Enums::ContactSortField::CONTACT_NAME,
        sort_descending: true
      }
    end
    let(:expected_variables) do
      {
        first: 50,
        after: 'previous-cursor',
        primaryOnly: false,
        query: 'Acme',
        sortOn: 'CONTACT_NAME',
        sortDescending: true
      }
    end
    let(:partial_envelope) do
      Printavo::ResponseEnvelope.new(
        data: {
          'contacts' => {
            'nodes' => [contact_data],
            'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
          }
        },
        errors: [{ 'message' => 'One field failed' }]
      )
    end

    before do
      allow(graphql).to receive(:query_envelope).and_return(envelope)
    end

    it 'returns one bounded page with cursor metadata' do
      page = resource.page(first: 50, after: 'previous-cursor')

      expect(page.records.map(&:id)).to eq(['123'])
      expect(page.has_next_page).to be true
      expect(page.end_cursor).to eq('cursor-1')
      expect(page.metadata).to eq('x-request-id' => 'request-1')
    end

    it 'sends documented filters without following the next cursor' do
      resource.page(**all_filters)

      expect(graphql).to have_received(:query_envelope).once.with(
        described_class::ALL_QUERY,
        variables: expected_variables
      )
    end

    it 'preserves successful records and sanitized partial errors' do
      allow(graphql).to receive(:query_envelope).and_return(partial_envelope)
      page = resource.page

      expect(page.records.map(&:id)).to eq(['123'])
      expect(page.errors).to eq([{ 'message' => 'One field failed' }])
      expect(page).to be_partial
    end

    it 'rejects unbounded page sizes before provider access' do
      expect { resource.page(first: 101) }
        .to raise_error(ArgumentError, 'first must be between 1 and 100')
      expect(graphql).not_to have_received(:query_envelope)
    end

    it 'rejects unknown filter names before provider access' do
      expect { resource.page(tenant_id: 'not-sdk-owned') }
        .to raise_error(ArgumentError, 'unknown contact filters: tenant_id')
      expect(graphql).not_to have_received(:query_envelope)
    end

    it 'rejects unknown sort vocabulary before provider access' do
      expect { resource.page(sort_on: 'EMAIL') }
        .to raise_error(ArgumentError, 'sort_on must be a Printavo::Enums::ContactSortField value')
      expect(graphql).not_to have_received(:query_envelope)
    end

    it 'keeps all as a single-page records convenience method' do
      expect(resource.all(first: 25)).to contain_exactly(an_instance_of(Printavo::Contact))
      expect(graphql).to have_received(:query_envelope).once
    end
  end

  describe '#find' do
    let(:contact_data) { fake_contact_attrs('id' => '123') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '123' })
        .and_return('contact' => contact_data)
    end

    it 'returns a Contact' do
      expect(resource.find('123')).to be_a(Printavo::Contact)
    end

    it 'maps id correctly' do
      expect(resource.find('123').id).to eq('123')
    end

    it 'coerces integer id to string' do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '123' })
        .and_return('contact' => contact_data)
      resource.find(123)
      expect(graphql).to have_received(:query)
        .with(described_class::FIND_QUERY, variables: { id: '123' })
    end
  end

  describe '#create' do
    let(:contact_data) { fake_contact_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('contactCreate' => contact_data)
    end

    it 'returns a Contact' do
      result = resource.create(first_name: 'Jane', email: 'jane@example.com')
      expect(result).to be_a(Printavo::Contact)
    end

    it 'camelizes snake_case input keys' do
      allow(graphql).to receive(:mutate)
        .with(anything, variables: { input: hash_including('firstName' => 'Jane') })
        .and_return('contactCreate' => contact_data)
      resource.create(first_name: 'Jane', email: 'jane@example.com')
      expect(graphql).to have_received(:mutate)
        .with(anything, variables: { input: hash_including('firstName' => 'Jane') })
    end
  end

  describe '#update' do
    let(:contact_data) { fake_contact_attrs('id' => '123') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('contactUpdate' => contact_data)
    end

    it 'returns a Contact' do
      expect(resource.update('123', phone: '555-000-1111')).to be_a(Printavo::Contact)
    end

    it 'passes the id as a string' do
      allow(graphql).to receive(:mutate)
        .with(anything, variables: hash_including(id: '123'))
        .and_return('contactUpdate' => contact_data)
      resource.update(123, phone: '555-000-1111')
      expect(graphql).to have_received(:mutate)
        .with(anything, variables: hash_including(id: '123'))
    end
  end

  describe '#delete' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETE_MUTATION, variables: { id: '123' })
        .and_return('contactDelete' => { 'id' => '123' })
    end

    it { expect(resource.delete('123')).to be_nil }
  end
end
