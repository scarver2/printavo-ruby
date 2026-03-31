# lib/printavo/resources/line_item_groups.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class LineItemGroups < Base
      ALL_QUERY        = File.read(File.join(__dir__, '../graphql/line_item_groups/all.graphql')).freeze
      FIND_QUERY       = File.read(File.join(__dir__, '../graphql/line_item_groups/find.graphql')).freeze
      CREATE_MUTATION  = File.read(File.join(__dir__, '../graphql/line_item_groups/create.graphql')).freeze
      CREATES_MUTATION = File.read(File.join(__dir__, '../graphql/line_item_groups/creates.graphql')).freeze
      UPDATE_MUTATION  = File.read(File.join(__dir__, '../graphql/line_item_groups/update.graphql')).freeze
      UPDATES_MUTATION = File.read(File.join(__dir__, '../graphql/line_item_groups/updates.graphql')).freeze
      DELETE_MUTATION  = File.read(File.join(__dir__, '../graphql/line_item_groups/delete.graphql')).freeze
      DELETES_MUTATION = File.read(File.join(__dir__, '../graphql/line_item_groups/deletes.graphql')).freeze

      def all(order_id:, first: 25, after: nil)
        fetch_page(order_id: order_id, first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::LineItemGroup.new(data['lineItemGroup'])
      end

      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: camelize_keys(input) })
        Printavo::LineItemGroup.new(data['lineItemGroupCreate'])
      end

      def creates(inputs)
        data = @graphql.mutate(CREATES_MUTATION, variables: { inputs: inputs.map { |i| camelize_keys(i) } })
        data['lineItemGroupCreates'].map { |attrs| Printavo::LineItemGroup.new(attrs) }
      end

      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION, variables: { id: id.to_s, input: camelize_keys(input) })
        Printavo::LineItemGroup.new(data['lineItemGroupUpdate'])
      end

      def updates(inputs)
        data = @graphql.mutate(UPDATES_MUTATION, variables: { inputs: inputs.map { |i| camelize_keys(i) } })
        data['lineItemGroupUpdates'].map { |attrs| Printavo::LineItemGroup.new(attrs) }
      end

      def delete(id)
        @graphql.mutate(DELETE_MUTATION, variables: { id: id.to_s })
        nil
      end

      def deletes(ids)
        @graphql.mutate(DELETES_MUTATION, variables: { ids: ids.map(&:to_s) })
        nil
      end

      private

      def fetch_page(order_id:, first: 25, after: nil, **)
        data = @graphql.query(
          ALL_QUERY,
          variables: { orderId: order_id.to_s, first: first, after: after }
        )
        nodes = data['order']['lineItemGroups']['nodes'].map { |attrs| Printavo::LineItemGroup.new(attrs) }
        page_info = data['order']['lineItemGroups']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
