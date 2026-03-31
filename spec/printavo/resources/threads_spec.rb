# spec/printavo/resources/threads_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Threads do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:thread_data) { fake_thread_attrs }
    let(:response_data) do
      {
        'order' => {
          'threads' => {
            'nodes' => [thread_data],
            'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
          }
        }
      }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { orderId: '99', first: 25, after: nil })
        .and_return(response_data)
    end

    it 'returns an array of Thread models' do
      expect(resource.all(order_id: '99')).to all(be_a(Printavo::Thread))
    end

    it 'maps attributes correctly' do
      thread = resource.all(order_id: '99').first
      expect(thread.id).to      eq(thread_data['id'])
      expect(thread.subject).to eq(thread_data['subject'])
    end
  end

  describe '#find' do
    let(:thread_data) { fake_thread_attrs('id' => '42') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '42' })
        .and_return('thread' => thread_data)
    end

    it { expect(resource.find('42')).to be_a(Printavo::Thread) }
    it { expect(resource.find('42').id).to eq('42') }
  end

  describe '#update' do
    let(:thread_data) { fake_thread_attrs('id' => '42') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('threadUpdate' => thread_data)
    end

    it { expect(resource.update('42', subject: 'New subject')).to be_a(Printavo::Thread) }
  end

  describe '#email_message_create' do
    let(:message_data) { { 'id' => '1', 'body' => 'Hello', 'createdAt' => '2026-03-30T12:00:00Z' } }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::EMAIL_MESSAGE_CREATE_MUTATION, variables: anything)
        .and_return('emailMessageCreate' => message_data)
    end

    it 'returns the raw message hash' do
      result = resource.email_message_create(thread_id: '42', body: 'Hello')
      expect(result).to eq(message_data)
    end
  end
end
