# lib/printavo/resources/orders.rb
module Printavo
  module Resources
    class Orders < Base
      ALL_QUERY = <<~GQL.freeze
        query Orders($first: Int, $after: String) {
          orders(first: $first, after: $after) {
            nodes {
              id
              nickname
              totalPrice
              status {
                id
                name
                color
              }
              customer {
                id
                firstName
                lastName
                email
                company
              }
            }
            pageInfo {
              hasNextPage
              endCursor
            }
          }
        }
      GQL

      FIND_QUERY = <<~GQL.freeze
        query Order($id: ID!) {
          order(id: $id) {
            id
            nickname
            totalPrice
            status {
              id
              name
              color
            }
            customer {
              id
              firstName
              lastName
              email
              company
            }
          }
        }
      GQL

      def all(first: 25, after: nil)
        fetch_page(first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Order.new(data['order'])
      end

      private

      def fetch_page(first: 25, after: nil, **)
        data = @graphql.query(ALL_QUERY, variables: { first: first, after: after })
        nodes = data['orders']['nodes'].map { |attrs| Printavo::Order.new(attrs) }
        page_info = data['orders']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
