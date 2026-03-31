# lib/printavo/resources/payment_requests.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class PaymentRequests < Base
      ALL_QUERY       = File.read(File.join(__dir__, '../graphql/payment_requests/all.graphql')).freeze
      FIND_QUERY      = File.read(File.join(__dir__, '../graphql/payment_requests/find.graphql')).freeze
      CREATE_MUTATION = File.read(File.join(__dir__, '../graphql/payment_requests/create.graphql')).freeze
      DELETE_MUTATION = File.read(File.join(__dir__, '../graphql/payment_requests/delete.graphql')).freeze

      def all(order_id:, first: 25, after: nil)
        fetch_page(order_id: order_id, first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::PaymentRequest.new(data['paymentRequest'])
      end

      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: camelize_keys(input) })
        Printavo::PaymentRequest.new(data['paymentRequestCreate'])
      end

      def delete(id)
        @graphql.mutate(DELETE_MUTATION, variables: { id: id.to_s })
        nil
      end

      private

      def fetch_page(order_id:, first: 25, after: nil, **)
        data = @graphql.query(
          ALL_QUERY,
          variables: { orderId: order_id.to_s, first: first, after: after }
        )
        nodes     = data['order']['paymentRequests']['nodes'].map { |attrs| Printavo::PaymentRequest.new(attrs) }
        page_info = data['order']['paymentRequests']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
