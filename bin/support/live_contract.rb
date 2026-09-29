# bin/support/live_contract.rb
# frozen_string_literal: true

module Printavo
  class LiveContract
    DOCUMENT = <<~GRAPHQL.freeze
      query PrintavoRubyLiveContract {
        queryRoot: __type(name: "Query") { fields { name } }
        mutationRoot: __type(name: "Mutation") { fields { name } }
        lineItem: __type(name: "LineItem") { fields { name } }
        transactionUnion: __type(name: "TransactionUnion") { possibleTypes { name } }
      }
    GRAPHQL

    EXPECTED_QUERY_FIELDS = %w[
      lineItemGroupPricing
      quote
      quotes
      transactionDetail
    ].freeze
    EXPECTED_MUTATION_FIELDS = %w[
      customAddressCreates
      customAddressDeletes
      customAddressUpdates
      feeCreates
      feeDeletes
      feeUpdates
      imprintCreates
      imprintDeletes
      imprintMockupCreates
      imprintUpdates
      lineItemCreates
      lineItemDeletes
      lineItemGroupCreates
      lineItemGroupDeletes
      lineItemGroupUpdates
      lineItemMockupCreates
      lineItemUpdates
      mockupDeletes
      productionFileCreates
      productionFileDeletes
    ].freeze
    EXPECTED_LINE_ITEM_FIELDS = %w[
      markupPercentage
      personalizations
      poLineItem
      priceReceipt
      productStatus
    ].freeze
    EXPECTED_TRANSACTION_TYPES = %w[
      Payment
      PaymentDispute
      Refund
      Return
      Void
    ].freeze

    def initialize(graphql)
      @graphql = graphql
    end

    def call
      data = @graphql.query(DOCUMENT)
      {
        query_fields: missing(data, 'queryRoot', 'fields', EXPECTED_QUERY_FIELDS),
        mutation_fields: missing(data, 'mutationRoot', 'fields', EXPECTED_MUTATION_FIELDS),
        line_item_fields: missing(data, 'lineItem', 'fields', EXPECTED_LINE_ITEM_FIELDS),
        transaction_types: missing(data, 'transactionUnion', 'possibleTypes', EXPECTED_TRANSACTION_TYPES)
      }
    end

    private

    def missing(data, type_key, collection_key, expected)
      actual = Array(data.dig(type_key, collection_key)).filter_map { |entry| entry['name'] }
      expected - actual
    end
  end
end
