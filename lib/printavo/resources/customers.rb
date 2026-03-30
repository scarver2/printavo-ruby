# lib/printavo/resources/customers.rb
module Printavo
  module Resources
    class Customers < Base
      ALL_QUERY = <<~GQL.freeze
        query Customers($first: Int, $after: String) {
          customers(first: $first, after: $after) {
            nodes {
              id
              firstName
              lastName
              email
              phone
              company
            }
            pageInfo {
              hasNextPage
              endCursor
            }
          }
        }
      GQL

      FIND_QUERY = <<~GQL.freeze
        query Customer($id: ID!) {
          customer(id: $id) {
            id
            firstName
            lastName
            email
            phone
            company
          }
        }
      GQL

      def all(first: 25, after: nil)
        fetch_page(first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Customer.new(data['customer'])
      end

      private

      def fetch_page(first: 25, after: nil, **)
        data = @graphql.query(ALL_QUERY, variables: { first: first, after: after })
        nodes = data['customers']['nodes'].map { |attrs| Printavo::Customer.new(attrs) }
        page_info = data['customers']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
