# lib/printavo/resources/invoices.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class Invoices < Base
      ALL_QUERY       = File.read(File.join(__dir__, '../graphql/invoices/all.graphql')).freeze
      FIND_QUERY      = File.read(File.join(__dir__, '../graphql/invoices/find.graphql')).freeze
      UPDATE_MUTATION = File.read(File.join(__dir__, '../graphql/invoices/update.graphql')).freeze

      def all(first: 25, after: nil)
        fetch_page(first: first, after: after).records
      end

      # Finds an invoice by ID.
      #
      # @param id [String, Integer]
      # @return [Printavo::Invoice]
      #
      # @example
      #   client.invoices.find("456")
      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Invoice.new(data['invoice'])
      end

      # Updates an existing invoice by ID.
      # Note: invoices are promoted from quotes — use +client.orders.create+ to originate.
      #
      # @param id [String, Integer]
      # @return [Printavo::Invoice]
      #
      # @example
      #   client.invoices.update("456", nickname: "Final Invoice", payment_due_at: "2026-05-01")
      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION,
                               variables: { id: id.to_s, input: camelize_keys(input) })
        Printavo::Invoice.new(data['invoiceUpdate'])
      end

      private

      def fetch_page(first: 25, after: nil, **)
        data = @graphql.query(ALL_QUERY, variables: { first: first, after: after })
        nodes = data['invoices']['nodes'].map { |attrs| Printavo::Invoice.new(attrs) }
        page_info = data['invoices']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
