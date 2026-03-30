# lib/printavo/resources/jobs.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class Jobs < Base
      ALL_QUERY  = File.read(File.join(__dir__, '../graphql/jobs/all.graphql')).freeze
      FIND_QUERY = File.read(File.join(__dir__, '../graphql/jobs/find.graphql')).freeze

      def all(order_id:, first: 25, after: nil)
        fetch_page(order_id: order_id, first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Job.new(data['lineItem'])
      end

      private

      def fetch_page(order_id:, first: 25, after: nil, **)
        data = @graphql.query(
          ALL_QUERY,
          variables: { orderId: order_id.to_s, first: first, after: after }
        )
        nodes = data['order']['lineItems']['nodes'].map { |attrs| Printavo::Job.new(attrs) }
        page_info = data['order']['lineItems']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
