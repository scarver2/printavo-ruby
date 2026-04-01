# lib/printavo/resources/mockups.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class Mockups < Base
      ALL_QUERY        = File.read(File.join(__dir__, '../graphql/mockups/all.graphql')).freeze
      FIND_QUERY       = File.read(File.join(__dir__, '../graphql/mockups/find.graphql')).freeze
      DELETE_MUTATION  = File.read(File.join(__dir__, '../graphql/mockups/delete.graphql')).freeze
      DELETES_MUTATION = File.read(File.join(__dir__, '../graphql/mockups/deletes.graphql')).freeze

      def all(order_id:, first: 25, after: nil)
        fetch_page(order_id: order_id, first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Mockup.new(data['mockup'])
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
        nodes     = data['order']['mockups']['nodes'].map { |attrs| Printavo::Mockup.new(attrs) }
        page_info = data['order']['mockups']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
