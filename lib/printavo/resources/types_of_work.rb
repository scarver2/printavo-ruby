# lib/printavo/resources/types_of_work.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class TypesOfWork < Base
      ALL_QUERY = File.read(File.join(__dir__, '../graphql/types_of_work/all.graphql')).freeze

      def all(first: 25, after: nil)
        fetch_page(first: first, after: after).records
      end

      private

      def fetch_page(first: 25, after: nil, **)
        data = @graphql.query(ALL_QUERY, variables: { first: first, after: after })
        nodes     = data['typesOfWork']['nodes'].map { |attrs| Printavo::TypeOfWork.new(attrs) }
        page_info = data['typesOfWork']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
