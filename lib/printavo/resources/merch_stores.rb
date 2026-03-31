# lib/printavo/resources/merch_stores.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class MerchStores < Base
      ALL_QUERY  = File.read(File.join(__dir__, '../graphql/merch_stores/all.graphql')).freeze
      FIND_QUERY = File.read(File.join(__dir__, '../graphql/merch_stores/find.graphql')).freeze

      def all(first: 25, after: nil)
        fetch_page(first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::MerchStore.new(data['merchStore'])
      end

      private

      def fetch_page(first: 25, after: nil, **)
        data = @graphql.query(ALL_QUERY, variables: { first: first, after: after })
        nodes = data['merchStores']['nodes'].map { |attrs| Printavo::MerchStore.new(attrs) }
        page_info = data['merchStores']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
