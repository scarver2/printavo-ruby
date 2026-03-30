# lib/printavo/resources/base.rb
module Printavo
  module Resources
    class Base
      def initialize(graphql)
        @graphql = graphql
      end

      # Yields each page of records as an Array, following cursors automatically.
      # Extra keyword arguments are forwarded to fetch_page (e.g. order_id: for Jobs).
      #
      # @param first [Integer] page size (default 25)
      # @yieldparam records [Array] one page of domain model objects
      #
      # @example
      #   client.customers.each_page(first: 50) do |records|
      #     records.each { |c| puts c.full_name }
      #   end
      def each_page(first: 25, **kwargs)
        after = nil
        loop do
          page = fetch_page(first: first, after: after, **kwargs)
          yield(page.records)
          break unless page.has_next_page

          after = page.end_cursor
        end
      end

      # Returns all records across all pages as a flat Array.
      # Extra keyword arguments are forwarded to fetch_page (e.g. order_id: for Jobs).
      #
      # @param first [Integer] page size per request (default 25)
      # @return [Array]
      #
      # @example
      #   all_customers = client.customers.all_pages
      #   all_jobs      = client.jobs.all_pages(order_id: "99")
      def all_pages(first: 25, **kwargs)
        [].tap { |all| each_page(first: first, **kwargs) { |records| all.concat(records) } }
      end

      private

      # Subclasses must implement: returns a Printavo::Page.
      def fetch_page(**)
        raise NotImplementedError, "#{self.class}#fetch_page is not implemented"
      end
    end
  end
end
