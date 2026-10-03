# bin/support/live_contract.rb
# frozen_string_literal: true

module Printavo
  # A bounded provider-schema probe for the SDK contracts under active development.
  # rubocop:disable-next Metrics/ClassLength
  class LiveContract
    DOCUMENT = <<~GRAPHQL
      query PrintavoRubyLiveContract {
        queryRoot: __type(name: "Query") {
          fields {
            name
            args { name type { ...TypeReference } }
            type { ...ReturnType }
          }
        }
        mutationRoot: __type(name: "Mutation") {
          fields { name args { name type { ...TypeReference } } }
        }
        lineItem: __type(name: "LineItem") { fields { name } }
        quote: __type(name: "Quote") { fields { name type { ...TypeReference } } }
        objectTimestamps: __type(name: "ObjectTimestamps") { fields { name type { ...TypeReference } } }
        lineItemCreatesInput: __type(name: "LineItemCreatesInput") {
          inputFields { name type { ...TypeReference } }
        }
        lineItemGroupCreatesInput: __type(name: "LineItemGroupCreatesInput") {
          inputFields { name type { ...TypeReference } }
        }
        transactionUnion: __type(name: "TransactionUnion") { possibleTypes { name } }
      }

      fragment TypeReference on __Type {
        kind
        name
        ofType {
          kind
          name
          ofType {
            kind
            name
            ofType { kind name }
          }
        }
      }

      fragment ReturnType on __Type {
        kind
        name
        fields { name }
        ofType {
          kind
          name
          fields { name }
          ofType { kind name fields { name } }
        }
      }
    GRAPHQL

    EXPECTED_QUERY_ARGUMENTS = {
      'lineItemGroupPricing' => { 'lineItemGroup' => 'LineItemGroupPricingInput!' },
      'quote' => { 'id' => 'ID!' },
      'transactionDetail' => { 'id' => 'ID!' }
    }.freeze
    EXPECTED_QUERY_FIELDS = (EXPECTED_QUERY_ARGUMENTS.keys + ['quotes']).sort.freeze
    EXPECTED_MUTATION_ARGUMENTS = {
      'customAddressCreates' => { 'inputs' => '[CustomAddressCreatesInput!]!' },
      'customAddressDeletes' => { 'ids' => '[ID!]!' },
      'customAddressUpdates' => { 'inputs' => '[CustomAddressUpdatesInput!]!' },
      'feeCreates' => { 'inputs' => '[FeeCreatesInput!]!' },
      'feeDeletes' => { 'ids' => '[ID!]!' },
      'feeUpdates' => { 'inputs' => '[FeeUpdatesInput!]!' },
      'imprintCreates' => { 'inputs' => '[ImprintCreatesInput!]!' },
      'imprintDeletes' => { 'ids' => '[ID!]!' },
      'imprintMockupCreates' => { 'inputs' => '[ImprintMockupCreatesInput!]!' },
      'imprintUpdates' => { 'inputs' => '[ImprintUpdatesInput!]!' },
      'lineItemCreate' => { 'input' => 'LineItemCreateInput!', 'lineItemGroupId' => 'ID!' },
      'lineItemCreates' => { 'inputs' => '[LineItemCreatesInput!]!' },
      'lineItemDeletes' => { 'ids' => '[ID!]!' },
      'lineItemGroupCreate' => { 'input' => 'LineItemGroupCreateInput!', 'parentId' => 'ID!' },
      'lineItemGroupCreates' => { 'inputs' => '[LineItemGroupCreatesInput!]!' },
      'lineItemGroupDeletes' => { 'ids' => '[ID!]!' },
      'lineItemGroupUpdates' => { 'inputs' => '[LineItemGroupUpdatesInput!]!' },
      'lineItemMockupCreates' => { 'inputs' => '[LineItemMockupCreatesInput!]!' },
      'lineItemUpdates' => { 'inputs' => '[LineItemUpdatesInput!]!' },
      'mockupDeletes' => { 'ids' => '[ID!]!' },
      'productionFileCreates' => { 'inputs' => '[ProductionFileCreatesInput!]!' },
      'productionFileDeletes' => { 'ids' => '[ID!]!' }
    }.freeze
    EXPECTED_MUTATION_FIELDS = EXPECTED_MUTATION_ARGUMENTS.keys.freeze
    EXPECTED_INPUT_FIELDS = {
      'lineItemCreatesInput' => {
        'input' => 'LineItemCreateInput!',
        'lineItemGroupId' => 'ID!'
      },
      'lineItemGroupCreatesInput' => {
        'input' => 'LineItemGroupCreateInput!',
        'parentId' => 'ID!'
      }
    }.freeze
    EXPECTED_QUOTE_FIELDS = {
      'contact' => 'Contact!',
      'createdAt' => 'ISO8601Date!',
      'id' => 'ID!',
      'nickname' => 'String',
      'status' => 'Status!',
      'timestamps' => 'ObjectTimestamps!',
      'total' => 'Float',
      'visualId' => 'ID'
    }.freeze
    EXPECTED_TIMESTAMP_FIELDS = { 'updatedAt' => 'ISO8601DateTime!' }.freeze
    EXPECTED_QUERY_RETURN_FIELDS = {
      'lineItemGroupPricing' => %w[defaultMarkupPercentage description price signature],
      'transactionDetail' => %w[
        amount
        category
        ccCardType
        ccLastFour
        description
        id
        portalTransactionId
        processing
        transactionDate
      ]
    }.freeze
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
        query_fields: missing_names(data, 'queryRoot', 'fields', EXPECTED_QUERY_FIELDS),
        query_arguments: missing_arguments(data, 'queryRoot', EXPECTED_QUERY_ARGUMENTS),
        query_return_fields: missing_return_fields(data),
        mutation_fields: missing_names(data, 'mutationRoot', 'fields', EXPECTED_MUTATION_FIELDS),
        mutation_arguments: missing_arguments(data, 'mutationRoot', EXPECTED_MUTATION_ARGUMENTS),
        input_fields: missing_input_fields(data),
        quote_fields: missing_typed_fields(data, 'quote', EXPECTED_QUOTE_FIELDS),
        timestamp_fields: missing_typed_fields(data, 'objectTimestamps', EXPECTED_TIMESTAMP_FIELDS),
        line_item_fields: missing_names(data, 'lineItem', 'fields', EXPECTED_LINE_ITEM_FIELDS),
        transaction_types: missing_names(data, 'transactionUnion', 'possibleTypes', EXPECTED_TRANSACTION_TYPES)
      }
    end

    private

    def missing_names(data, type_key, collection_key, expected)
      actual = Array(data.dig(type_key, collection_key)).filter_map { |entry| entry['name'] }
      expected - actual
    end

    def missing_arguments(data, root_key, expected)
      fields = entries_by_name(data.dig(root_key, 'fields'))

      expected.each_with_object([]) do |(field_name, arguments), missing|
        actual = entries_by_name(fields.dig(field_name, 'args'))
        arguments.each do |argument_name, signature|
          next if type_signature(actual.dig(argument_name, 'type')) == signature

          missing << "#{field_name}(#{argument_name}: #{signature})"
        end
      end
    end

    def missing_input_fields(data)
      EXPECTED_INPUT_FIELDS.each_with_object([]) do |(type_key, fields), missing|
        actual = entries_by_name(data.dig(type_key, 'inputFields'))
        fields.each do |field_name, signature|
          next if type_signature(actual.dig(field_name, 'type')) == signature

          missing << "#{type_name(type_key)}.#{field_name}: #{signature}"
        end
      end
    end

    def missing_typed_fields(data, type_key, expected)
      actual = entries_by_name(data.dig(type_key, 'fields'))

      expected.each_with_object([]) do |(field_name, signature), missing|
        next if type_signature(actual.dig(field_name, 'type')) == signature

        missing << "#{type_name(type_key)}.#{field_name}: #{signature}"
      end
    end

    def missing_return_fields(data)
      query_fields = entries_by_name(data.dig('queryRoot', 'fields'))

      EXPECTED_QUERY_RETURN_FIELDS.each_with_object([]) do |(query_name, expected), missing|
        actual = return_field_names(query_fields.dig(query_name, 'type'))
        (expected - actual).each { |field_name| missing << "#{query_name}.#{field_name}" }
      end
    end

    def return_field_names(type)
      current = type
      current = current['ofType'] while current && current['kind'] != 'OBJECT'
      Array(current&.fetch('fields', nil)).filter_map { |field| field['name'] }
    end

    def entries_by_name(entries)
      Array(entries).to_h { |entry| [entry['name'], entry] }
    end

    def type_signature(type)
      return unless type
      return "#{type_signature(type['ofType'])}!" if type['kind'] == 'NON_NULL'
      return "[#{type_signature(type['ofType'])}]" if type['kind'] == 'LIST'

      type['name']
    end

    def type_name(key)
      key.sub(/\A./, &:upcase)
    end
  end
end
