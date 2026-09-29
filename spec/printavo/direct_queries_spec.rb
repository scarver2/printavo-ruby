# spec/printavo/direct_queries_spec.rb
# frozen_string_literal: true

require 'spec_helper'

# These two resource operations share one focused provider-contract spec.
# rubocop:disable RSpec/DescribeClass
RSpec.describe 'direct API queries' do
  let(:graphql) { instance_double(Printavo::GraphqlClient) }

  it 'calculates line item group pricing with camelized input' do
    resource = Printavo::Resources::LineItemGroups.new(graphql)
    allow(graphql).to receive(:query).and_return(
      'lineItemGroupPricing' => { 'price' => 12.5, 'signature' => 'signed' }
    )

    result = resource.pricing(pricing_matrix_id: '7')

    expect(result).to be_a(Printavo::LineItemGroupPricing)
    expect(result.price).to eq(12.5)
    expect(graphql).to have_received(:query).with(resource.class::PRICING_QUERY,
                                                  variables: { lineItemGroup: { 'pricingMatrixId' => '7' } })
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
# rubocop:enable RSpec/DescribeClass
