# spec/printavo/live_contract_spec.rb
# frozen_string_literal: true

require 'spec_helper'
require_relative '../../bin/support/live_contract'

RSpec.describe Printavo::LiveContract do
  subject(:contract) { described_class.new(graphql) }

  let(:graphql) { instance_double(Printavo::GraphqlClient) }
  let(:data) do
    {
      'queryRoot' => { 'fields' => described_class::EXPECTED_QUERY_FIELDS.map { |name| { 'name' => name } } },
      'mutationRoot' => { 'fields' => described_class::EXPECTED_MUTATION_FIELDS.map { |name| { 'name' => name } } },
      'lineItem' => { 'fields' => described_class::EXPECTED_LINE_ITEM_FIELDS.map { |name| { 'name' => name } } },
      'transactionUnion' => {
        'possibleTypes' => described_class::EXPECTED_TRANSACTION_TYPES.map { |name| { 'name' => name } }
      }
    }
  end

  before { allow(graphql).to receive(:query).with(described_class::DOCUMENT).and_return(data) }

  it 'reports no missing contract members for the expected schema' do
    expect(contract.call.values).to all(be_empty)
  end

  it 'reports missing contract members without inspecting account data' do
    data['queryRoot']['fields'].reject! { |field| field['name'] == 'quote' }

    expect(contract.call[:query_fields]).to eq(['quote'])
  end
end
