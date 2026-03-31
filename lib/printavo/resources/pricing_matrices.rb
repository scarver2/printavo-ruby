# lib/printavo/resources/pricing_matrices.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class PricingMatrices < Base
      ALL_QUERY  = File.read(File.join(__dir__, '../graphql/pricing_matrices/all.graphql')).freeze
      FIND_QUERY = File.read(File.join(__dir__, '../graphql/pricing_matrices/find.graphql')).freeze

      def all(first: 25, after: nil)
        fetch_page(first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::PricingMatrix.new(data['pricingMatrix'])
      end

      private

      def fetch_page(first: 25, after: nil, **)
        data = @graphql.query(ALL_QUERY, variables: { first: first, after: after })
        nodes = data['pricingMatrices']['nodes'].map { |attrs| Printavo::PricingMatrix.new(attrs) }
        page_info = data['pricingMatrices']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
