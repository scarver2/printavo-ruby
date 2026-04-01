# spec/printavo/resources/types_of_work_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::TypesOfWork do
  let(:graphql)  { instance_double(Printavo::GraphqlClient) }
  let(:resource) { described_class.new(graphql) }

  describe '#all' do
    let(:tow_data) { fake_type_of_work_attrs }
    let(:response_data) do
      { 'typesOfWork' => {
        'nodes' => [tow_data],
        'pageInfo' => { 'hasNextPage' => false, 'endCursor' => nil }
      } }
    end

    before do
      allow(graphql).to receive(:query)
        .with(described_class::ALL_QUERY, variables: { first: 25, after: nil })
        .and_return(response_data)
    end

    it { expect(resource.all).to all(be_a(Printavo::TypeOfWork)) }
    it { expect(resource.all.first.name).to eq(tow_data['name']) }
  end
end
