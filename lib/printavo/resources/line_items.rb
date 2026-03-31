# lib/printavo/resources/line_items.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class LineItems < Base
      ALL_QUERY             = File.read(File.join(__dir__, '../graphql/line_items/all.graphql')).freeze
      FIND_QUERY            = File.read(File.join(__dir__, '../graphql/line_items/find.graphql')).freeze
      CREATE_MUTATION       = File.read(File.join(__dir__, '../graphql/line_items/create.graphql')).freeze
      CREATES_MUTATION      = File.read(File.join(__dir__, '../graphql/line_items/creates.graphql')).freeze
      UPDATE_MUTATION       = File.read(File.join(__dir__, '../graphql/line_items/update.graphql')).freeze
      UPDATES_MUTATION      = File.read(File.join(__dir__, '../graphql/line_items/updates.graphql')).freeze
      DELETE_MUTATION       = File.read(File.join(__dir__, '../graphql/line_items/delete.graphql')).freeze
      DELETES_MUTATION      = File.read(File.join(__dir__, '../graphql/line_items/deletes.graphql')).freeze
      MOCKUP_CREATE_MUTATION  = File.read(File.join(__dir__, '../graphql/line_items/mockup_create.graphql')).freeze
      MOCKUP_CREATES_MUTATION = File.read(File.join(__dir__, '../graphql/line_items/mockup_creates.graphql')).freeze

      def all(line_item_group_id:, first: 25, after: nil)
        fetch_page(line_item_group_id: line_item_group_id, first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::LineItem.new(data['lineItem'])
      end

      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: camelize_keys(input) })
        Printavo::LineItem.new(data['lineItemCreate'])
      end

      def creates(inputs)
        data = @graphql.mutate(CREATES_MUTATION, variables: { inputs: inputs.map { |i| camelize_keys(i) } })
        data['lineItemCreates'].map { |attrs| Printavo::LineItem.new(attrs) }
      end

      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION, variables: { id: id.to_s, input: camelize_keys(input) })
        Printavo::LineItem.new(data['lineItemUpdate'])
      end

      def updates(inputs)
        data = @graphql.mutate(UPDATES_MUTATION, variables: { inputs: inputs.map { |i| camelize_keys(i) } })
        data['lineItemUpdates'].map { |attrs| Printavo::LineItem.new(attrs) }
      end

      def delete(id)
        @graphql.mutate(DELETE_MUTATION, variables: { id: id.to_s })
        nil
      end

      def deletes(ids)
        @graphql.mutate(DELETES_MUTATION, variables: { ids: ids.map(&:to_s) })
        nil
      end

      def mockup_create(**input)
        data = @graphql.mutate(MOCKUP_CREATE_MUTATION, variables: { input: camelize_keys(input) })
        data['lineItemMockupCreate']
      end

      def mockup_creates(inputs)
        data = @graphql.mutate(MOCKUP_CREATES_MUTATION, variables: { inputs: inputs.map { |i| camelize_keys(i) } })
        data['lineItemMockupCreates']
      end

      private

      def fetch_page(line_item_group_id:, first: 25, after: nil, **)
        data = @graphql.query(
          ALL_QUERY,
          variables: { lineItemGroupId: line_item_group_id.to_s, first: first, after: after }
        )
        nodes = data['lineItemGroup']['lineItems']['nodes'].map { |attrs| Printavo::LineItem.new(attrs) }
        page_info = data['lineItemGroup']['lineItems']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
