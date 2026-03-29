# lib/printavo/resources/jobs.rb
module Printavo
  module Resources
    class Jobs < Base
      ALL_QUERY = <<~GQL.freeze
        query LineItems($orderId: ID!, $first: Int, $after: String) {
          order(id: $orderId) {
            lineItems(first: $first, after: $after) {
              nodes {
                id
                name
                quantity
                price
                taxable
              }
              pageInfo {
                hasNextPage
                endCursor
              }
            }
          }
        }
      GQL

      FIND_QUERY = <<~GQL.freeze
        query LineItem($id: ID!) {
          lineItem(id: $id) {
            id
            name
            quantity
            price
            taxable
          }
        }
      GQL

      def all(order_id:, first: 25, after: nil)
        data = @graphql.query(ALL_QUERY, variables: { orderId: order_id.to_s, first: first, after: after })
        data['order']['lineItems']['nodes'].map { |attrs| Printavo::Job.new(attrs) }
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Job.new(data['lineItem'])
      end
    end
  end
end
