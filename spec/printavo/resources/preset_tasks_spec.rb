# spec/printavo/resources/preset_tasks_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::PresetTasks do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#find' do
    let(:task_data) { fake_preset_task_attrs('id' => '20') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '20' })
        .and_return('presetTask' => task_data)
    end

    it { expect(resource.find('20')).to be_a(Printavo::PresetTask) }
    it { expect(resource.find('20').id).to eq('20') }
  end

  describe '#create' do
    let(:task_data) { fake_preset_task_attrs }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::CREATE_MUTATION, variables: anything)
        .and_return('presetTaskCreate' => task_data)
    end

    it { expect(resource.create(body: 'Send invoice', due_offset_days: 3)).to be_a(Printavo::PresetTask) }
  end

  describe '#update' do
    let(:task_data) { fake_preset_task_attrs('id' => '20') }

    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::UPDATE_MUTATION, variables: anything)
        .and_return('presetTaskUpdate' => task_data)
    end

    it { expect(resource.update('20', body: 'Updated body')).to be_a(Printavo::PresetTask) }
  end

  describe '#delete' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETE_MUTATION, variables: { id: '20' })
        .and_return('presetTaskDelete' => { 'id' => '20' })
    end

    it { expect(resource.delete('20')).to be_nil }
  end
end
