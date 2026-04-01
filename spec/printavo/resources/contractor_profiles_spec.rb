# spec/printavo/resources/contractor_profiles_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::ContractorProfiles do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:profile_data) { fake_contractor_profile_attrs }
    let(:response_data) do
      { 'contractorProfiles' => {
        'nodes' => [profile_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all).to all(be_a(Printavo::ContractorProfile)) }
    it { expect(resource.all.first.name).to eq(profile_data['name']) }
  end

  describe '#find' do
    let(:profile_data) { fake_contractor_profile_attrs('id' => '30') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '30' })
        .and_return('contractorProfile' => profile_data)
    end

    it { expect(resource.find('30')).to be_a(Printavo::ContractorProfile) }
    it { expect(resource.find('30').id).to eq('30') }
  end
end
