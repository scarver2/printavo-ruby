# spec/printavo/resources/mockups_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Mockups do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:mockup_data) { fake_mockup_attrs }
    let(:response_data) do
      { 'order' => { 'mockups' => {
        'nodes' => [mockup_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { orderId: '99', first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all(order_id: '99')).to all(be_a(Printavo::Mockup)) }
  end

  describe '#find' do
    let(:mockup_data) { fake_mockup_attrs('id' => '20') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '20' })
        .and_return('mockup' => mockup_data)
    end

    it { expect(resource.find('20')).to be_a(Printavo::Mockup) }
    it { expect(resource.find('20').id).to eq('20') }
  end

  describe '#delete' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETE_MUTATION, variables: { id: '20' })
        .and_return('mockupDelete' => { 'id' => '20' })
    end

    it { expect(resource.delete('20')).to be_nil }
  end

  describe '#deletes' do
    before do
      allow(graphql).to receive(:mutate)
        .with(described_class::DELETES_MUTATION, variables: { ids: %w[1 2] })
        .and_return('mockupDeletes' => [{ 'id' => '1' }, { 'id' => '2' }])
    end

    it { expect(resource.deletes([1, 2])).to be_nil }
  end
end
