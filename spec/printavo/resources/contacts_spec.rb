# spec/printavo/resources/contacts_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Contacts do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

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
end
