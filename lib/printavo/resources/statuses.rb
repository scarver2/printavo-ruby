# lib/printavo/resources/statuses.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class Statuses < Base
      ALL_QUERY  = File.read(File.join(__dir__, '../graphql/statuses/all.graphql')).freeze
      FIND_QUERY = File.read(File.join(__dir__, '../graphql/statuses/find.graphql')).freeze

      def all(first: 100, after: nil)
        fetch_page(first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Status.new(data['status'])
      end

      # Returns a Hash{Symbol => Status} keyed by Status#key for O(1) lookup.
      # Pairs with Order#status_key:
      #   registry = client.statuses.registry
      #   registry[order.status_key]  #=> <Printavo::Status>
      def registry
        all.to_h { |status| [status.key, status] }
      end

      private

      def fetch_page(first: 100, after: nil, **)
        data = @graphql.query(ALL_QUERY, variables: { first: first, after: after })
        nodes = data['statuses']['nodes'].map { |attrs| Printavo::Status.new(attrs) }
        page_info = data['statuses']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
