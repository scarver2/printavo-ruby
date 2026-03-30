# lib/printavo/resources/inquiries.rb
module Printavo
  module Resources
    class Inquiries < Base
      ALL_QUERY = <<~GQL.freeze
        query Inquiries($first: Int, $after: String) {
          inquiries(first: $first, after: $after) {
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
        query Inquiry($id: ID!) {
          inquiry(id: $id) {
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
        data = @graphql.query(ALL_QUERY, variables: { first: first, after: after })
        data['inquiries']['nodes'].map { |attrs| Printavo::Inquiry.new(attrs) }
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Inquiry.new(data['inquiry'])
      end
    end
  end
end
