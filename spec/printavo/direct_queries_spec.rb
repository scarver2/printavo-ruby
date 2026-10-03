# spec/printavo/direct_queries_spec.rb
# frozen_string_literal: true

require 'spec_helper'

# These two resource operations share one focused provider-contract spec.
# rubocop:disable-next RSpec/DescribeClass
RSpec.describe 'direct API queries' do
  let(:graphql) { instance_double(Printavo::GraphqlClient) }
  let(:pricing_input) do
    {
      enabled_columns: { markupPercentage: true },
      imprints: [],
      line_items: [{ description: 'Core Cotton Tee', position: 0 }],
      position: 0
    }
  end
  let(:expected_pricing_input) do
    {
      'enabledColumns' => { markupPercentage: true },
      'imprints' => [],
      'lineItems' => [{ description: 'Core Cotton Tee', position: 0 }],
      'position' => 0
    }
  end

  it 'calculates line item group pricing with the documented input shape' do
    resource = Printavo::Resources::LineItemGroups.new(graphql)
    allow(graphql).to receive(:query).and_return(
      'lineItemGroupPricing' => { 'price' => 12.5, 'signature' => 'signed' }
    )

    result = resource.pricing(**pricing_input)

    expect(result).to be_a(Printavo::LineItemGroupPricing).and have_attributes(price: 12.5)
    expect(graphql).to have_received(:query).with(
      resource.class::PRICING_QUERY,
      variables: { lineItemGroup: expected_pricing_input }
    )
  end

  it 'retrieves transaction details by ID' do
    resource = Printavo::Resources::Transactions.new(graphql)
    allow(graphql).to receive(:query).and_return(
      'transactionDetail' => { 'id' => '9', 'amount' => 42.5, 'processing' => false }
    )

    result = resource.detail(9)

    expect(result).to be_a(Printavo::TransactionDetails)
    expect(result.id).to eq('9')
    expect(graphql).to have_received(:query).with(resource.class::DETAIL_QUERY,
                                                  variables: { id: '9' })
  end
end
