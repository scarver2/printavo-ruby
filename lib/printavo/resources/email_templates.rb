# lib/printavo/resources/email_templates.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class EmailTemplates < Base
      ALL_QUERY  = File.read(File.join(__dir__, '../graphql/email_templates/all.graphql')).freeze
      FIND_QUERY = File.read(File.join(__dir__, '../graphql/email_templates/find.graphql')).freeze

      def all(first: 25, after: nil)
        fetch_page(first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::EmailTemplate.new(data['emailTemplate'])
      end

      private

      def fetch_page(first: 25, after: nil, **)
        data = @graphql.query(ALL_QUERY, variables: { first: first, after: after })
        nodes     = data['emailTemplates']['nodes'].map { |attrs| Printavo::EmailTemplate.new(attrs) }
        page_info = data['emailTemplates']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
