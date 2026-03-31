# spec/printavo/resources/preset_task_groups_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::PresetTaskGroups do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:group_data) { fake_preset_task_group_attrs }
    let(:response_data) do
      { 'presetTaskGroups' => {
        'nodes' => [group_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all).to all(be_a(Printavo::PresetTaskGroup)) }
    it { expect(resource.all.first.name).to eq(group_data['name']) }
  end

  describe '#find' do
    let(:group_data) { fake_preset_task_group_attrs('id' => '30') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '30' })
        .and_return('presetTaskGroup' => group_data)
    end

    it { expect(resource.find('30')).to be_a(Printavo::PresetTaskGroup) }
    it { expect(resource.find('30').id).to eq('30') }
  end

  describe '#create' do
    let(:group_data) { fake_preset_task_group_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('presetTaskGroupCreate' => group_data)
    end

    it { expect(resource.create(name: 'Onboarding')).to be_a(Printavo::PresetTaskGroup) }
  end

  describe '#update' do
    let(:group_data) { fake_preset_task_group_attrs('id' => '30') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('presetTaskGroupUpdate' => group_data)
    end

    it { expect(resource.update('30', name: 'Updated Group')).to be_a(Printavo::PresetTaskGroup) }
  end

  describe '#delete' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETE_MUTATION, variables: { id: '30' })
        .and_return('presetTaskGroupDelete' => { 'id' => '30' })
    end

    it { expect(resource.delete('30')).to be_nil }
  end

  describe '#apply' do
    let(:tasks_data) { [fake_task_attrs, fake_task_attrs] }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::APPLY_MUTATION, variables: { id: '30', orderId: '99' })
        .and_return('presetTaskGroupApply' => tasks_data)
    end

    it { expect(resource.apply('30', order_id: '99')).to all(be_a(Printavo::Task)) }
  end
end
