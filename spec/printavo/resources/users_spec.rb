# spec/printavo/resources/users_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::Users do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:user_data) { fake_user_attrs }
    let(:response_data) do
      { 'users' => {
        'nodes' => [user_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all).to all(be_a(Printavo::User)) }
    it { expect(resource.all.first.email).to eq(user_data['email']) }
  end

  describe '#find' do
    let(:user_data) { fake_user_attrs('id' => '10') }

    before do
      allow(graphql).to receive(:query)
        .with(described_class::FIND_QUERY, variables: { id: '10' })
        .and_return('user' => user_data)
    end

    it { expect(resource.find('10')).to be_a(Printavo::User) }
    it { expect(resource.find('10').id).to eq('10') }
  end
end
