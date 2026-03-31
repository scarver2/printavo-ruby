# spec/printavo/resources/tasks_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Tasks do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:task_data) { fake_task_attrs }
    let(:response_data) do
      {
        'tasks' => {
          'nodes' => [task_data],
          'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
        }
      }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it 'returns an array of Task models' do
      expect(resource.all).to all(be_a(Printavo::Task))
    end

    it 'maps attributes correctly' do
      task = resource.all.first
      expect(task.id).to   eq(task_data['id'])
      expect(task.body).to eq(task_data['body'])
    end
  end

  describe '#find' do
    let(:task_data) { fake_task_attrs('id' => '789') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '789' })
        .and_return('task' => task_data)
    end

    it { expect(resource.find('789')).to be_a(Printavo::Task) }
    it { expect(resource.find('789').id).to eq('789') }
  end

  describe '#create' do
    let(:task_data) { fake_task_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('taskCreate' => task_data)
    end

    it { expect(resource.create(body: 'Follow up with customer')).to be_a(Printavo::Task) }
  end

  describe '#update' do
    let(:task_data) { fake_task_attrs('id' => '789') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('taskUpdate' => task_data)
    end

    it { expect(resource.update('789', body: 'Updated body')).to be_a(Printavo::Task) }

    it 'camelizes snake_case input keys' do
      allow(graphql).to receive(:mutate)
        .with(anything, variables: { id: '789', input: hash_including('dueAt' => '2026-04-01') })
        .and_return('taskUpdate' => task_data)
      resource.update('789', due_at: '2026-04-01')
      expect(graphql).to have_received(:mutate)
        .with(anything, variables: { id: '789', input: hash_including('dueAt' => '2026-04-01') })
    end
  end

  describe '#complete' do
    let(:task_data) { fake_task_attrs('completedAt' => Time.now.utc.iso8601) }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('taskUpdate' => task_data)
    end

    it 'returns a completed Task' do
      expect(resource.complete('789').completed?).to be true
    end
  end

  describe '#delete' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETE_MUTATION, variables: { id: '789' })
        .and_return('taskDelete' => { 'id' => '789' })
    end

    it { expect(resource.delete('789')).to be_nil }
  end
end
