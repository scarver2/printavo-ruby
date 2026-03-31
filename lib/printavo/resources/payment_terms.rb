# lib/printavo/resources/payment_terms.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class PaymentTerms < Base
      ALL_QUERY        = File.read(File.join(__dir__, '../graphql/payment_terms/all.graphql')).freeze
      FIND_QUERY       = File.read(File.join(__dir__, '../graphql/payment_terms/find.graphql')).freeze
      CREATE_MUTATION  = File.read(File.join(__dir__, '../graphql/payment_terms/create.graphql')).freeze
      UPDATE_MUTATION  = File.read(File.join(__dir__, '../graphql/payment_terms/update.graphql')).freeze
      ARCHIVE_MUTATION = File.read(File.join(__dir__, '../graphql/payment_terms/archive.graphql')).freeze

      def all(first: 25, after: nil)
        fetch_page(first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::PaymentTerm.new(data['paymentTerm'])
      end

      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: camelize_keys(input) })
        Printavo::PaymentTerm.new(data['paymentTermCreate'])
      end

      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION, variables: { id: id.to_s, input: camelize_keys(input) })
        Printavo::PaymentTerm.new(data['paymentTermUpdate'])
      end

      def archive(id)
        @graphql.mutate(ARCHIVE_MUTATION, variables: { id: id.to_s })
        nil
      end

      private

      def fetch_page(first: 25, after: nil, **)
        data = @graphql.query(ALL_QUERY, variables: { first: first, after: after })
        nodes     = data['paymentTerms']['nodes'].map { |attrs| Printavo::PaymentTerm.new(attrs) }
        page_info = data['paymentTerms']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
