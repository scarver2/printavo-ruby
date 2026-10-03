# spec/printavo/live_contract_spec.rb
# frozen_string_literal: true

require 'spec_helper'
require_relative '../../bin/support/live_contract'

RSpec.describe Printavo::LiveContract do
  subject(:contract) { described_class.new(graphql) }

  let(:graphql) { instance_double(Printavo::GraphqlClient) }
  let(:query_fields) do
    described_class::EXPECTED_QUERY_FIELDS.map do |name|
      arguments = described_class::EXPECTED_QUERY_ARGUMENTS.fetch(name, {})
      field(name, arguments, described_class::EXPECTED_QUERY_RETURN_FIELDS.fetch(name, []))
    end
  end
  let(:mutation_fields) do
    described_class::EXPECTED_MUTATION_ARGUMENTS.map { |name, arguments| field(name, arguments) }
  end
  let(:data) do
    {
      'queryRoot' => { 'fields' => query_fields },
      'mutationRoot' => { 'fields' => mutation_fields },
      'lineItem' => { 'fields' => named_entries(described_class::EXPECTED_LINE_ITEM_FIELDS) },
      'quote' => { 'fields' => typed_entries(described_class::EXPECTED_QUOTE_FIELDS) },
      'objectTimestamps' => { 'fields' => typed_entries(described_class::EXPECTED_TIMESTAMP_FIELDS) },
      'lineItemCreatesInput' => {
        'inputFields' => typed_entries(described_class::EXPECTED_INPUT_FIELDS.fetch('lineItemCreatesInput'))
      },
      'lineItemGroupCreatesInput' => {
        'inputFields' => typed_entries(described_class::EXPECTED_INPUT_FIELDS.fetch('lineItemGroupCreatesInput'))
      },
      'transactionUnion' => {
        'possibleTypes' => named_entries(described_class::EXPECTED_TRANSACTION_TYPES)
      }
    }
  end

  before { allow(graphql).to receive(:query).with(described_class::DOCUMENT).and_return(data) }

  it 'reports no missing contract members for the expected schema' do
    expect(contract.call.values).to all(be_empty)
    expect(graphql).to have_received(:query).with(described_class::DOCUMENT).once
  end

  it 'reports a missing operation without inspecting account data' do
    data['queryRoot']['fields'].reject! { |entry| entry['name'] == 'quote' }

    expect(contract.call).to include(
      query_fields: ['quote'],
      query_arguments: ['quote(id: ID!)']
    )
  end

  it 'reports mutation argument type mismatches' do
    argument('lineItemCreates', 'inputs')['type'] = type_reference('[LineItemCreateInput!]!')

    expect(contract.call[:mutation_arguments]).to eq(
      ['lineItemCreates(inputs: [LineItemCreatesInput!]!)']
    )
  end

  it 'reports missing required parent IDs in batch input objects' do
    data['lineItemGroupCreatesInput']['inputFields'].reject! { |entry| entry['name'] == 'parentId' }

    expect(contract.call[:input_fields]).to eq(['LineItemGroupCreatesInput.parentId: ID!'])
  end

  it 'reports an unsupported Quote timestamp shape' do
    quote_timestamps = data['quote']['fields'].find { |entry| entry['name'] == 'timestamps' }
    quote_timestamps['type'] = type_reference('ISO8601DateTime!')

    expect(contract.call[:quote_fields]).to eq(['Quote.timestamps: ObjectTimestamps!'])
  end

  it 'reports fields selected by direct queries that the return type lacks' do
    transaction_detail = data['queryRoot']['fields'].find { |entry| entry['name'] == 'transactionDetail' }
    transaction_detail['type']['fields'].reject! { |entry| entry['name'] == 'transactionDate' }

    expect(contract.call[:query_return_fields]).to eq(['transactionDetail.transactionDate'])
  end

  def argument(field_name, argument_name)
    operation = data['mutationRoot']['fields'].find { |entry| entry['name'] == field_name }
    operation['args'].find { |entry| entry['name'] == argument_name }
  end

  def field(name, arguments, return_fields = [])
    {
      'name' => name,
      'args' => typed_entries(arguments),
      'type' => {
        'kind' => 'OBJECT',
        'name' => "#{name}Result",
        'fields' => named_entries(return_fields)
      }
    }
  end

  def typed_entries(entries)
    entries.map { |name, signature| { 'name' => name, 'type' => type_reference(signature) } }
  end

  def named_entries(names)
    names.map { |name| { 'name' => name } }
  end

  def type_reference(signature)
    if signature.end_with?('!')
      { 'kind' => 'NON_NULL', 'name' => nil, 'ofType' => type_reference(signature.delete_suffix('!')) }
    elsif signature.start_with?('[')
      { 'kind' => 'LIST', 'name' => nil, 'ofType' => type_reference(signature[1..-2]) }
    else
      { 'kind' => 'NAMED', 'name' => signature, 'ofType' => nil }
    end
  end
end
