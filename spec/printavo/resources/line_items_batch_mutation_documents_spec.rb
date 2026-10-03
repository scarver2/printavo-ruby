# spec/printavo/batch_mutation_contract_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Printavo::Resources::LineItems do
  expected_input_types = {
    'custom_addresses/creates.graphql' => '[CustomAddressCreatesInput!]!',
    'custom_addresses/updates.graphql' => '[CustomAddressUpdatesInput!]!',
    'fees/creates.graphql' => '[FeeCreatesInput!]!',
    'fees/updates.graphql' => '[FeeUpdatesInput!]!',
    'imprints/creates.graphql' => '[ImprintCreatesInput!]!',
    'imprints/updates.graphql' => '[ImprintUpdatesInput!]!',
    'imprints/mockup_creates.graphql' => '[ImprintMockupCreatesInput!]!',
    'line_item_groups/creates.graphql' => '[LineItemGroupCreatesInput!]!',
    'line_item_groups/updates.graphql' => '[LineItemGroupUpdatesInput!]!',
    'line_items/creates.graphql' => '[LineItemCreatesInput!]!',
    'line_items/updates.graphql' => '[LineItemUpdatesInput!]!',
    'line_items/mockup_creates.graphql' => '[LineItemMockupCreatesInput!]!',
    'production_files/creates.graphql' => '[ProductionFileCreatesInput!]!'
  }

  expected_input_types.each do |relative_path, input_type|
    it "uses #{input_type} in #{relative_path}" do
      document = File.read(File.expand_path("../../../lib/printavo/graphql/#{relative_path}", __dir__))

      expect(document).to include("$inputs: #{input_type}")
    end
  end

  {
    'line_items/create.graphql' => [
      '$lineItemGroupId: ID!',
      'lineItemCreate(lineItemGroupId: $lineItemGroupId, input: $input)'
    ],
    'line_item_groups/create.graphql' => [
      '$parentId: ID!',
      'lineItemGroupCreate(parentId: $parentId, input: $input)'
    ]
  }.each do |relative_path, contract_fragments|
    it "sends the required parent ID in #{relative_path}" do
      document = File.read(File.expand_path("../../../lib/printavo/graphql/#{relative_path}", __dir__))

      expect(document).to include(*contract_fragments)
    end
  end
end
