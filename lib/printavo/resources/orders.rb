# lib/printavo/resources/orders.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class Orders < Base
      ALL_QUERY      = File.read(File.join(__dir__, '../graphql/orders/all.graphql')).freeze
      FIND_QUERY     = File.read(File.join(__dir__, '../graphql/orders/find.graphql')).freeze
      # Printavo creates orders as quotes first; the mutation is quoteCreate.
      CREATE_MUTATION        = File.read(File.join(__dir__, '../graphql/orders/create.graphql')).freeze
      UPDATE_MUTATION        = File.read(File.join(__dir__, '../graphql/orders/update.graphql')).freeze
      # statusUpdate returns an OrderUnion (Quote | Invoice) — requires fragments.
      UPDATE_STATUS_MUTATION = File.read(File.join(__dir__, '../graphql/orders/update_status.graphql')).freeze

      def all(first: 25, after: nil)
        fetch_page(first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Order.new(data['order'])
      end

      # Creates a new order (quote) in Printavo.
      # Requires at minimum +contact:+ (IDInput), +due_at:+, and +customer_due_at:+.
      #
      # @return [Printavo::Order]
      #
      # @example
      #   client.orders.create(
      #     contact: { id: "456" },
      #     due_at: "2026-06-01T09:00:00Z",
      #     customer_due_at: "2026-06-01"
      #   )
      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: camelize_keys(input) })
        build_order(data['quoteCreate'])
      end

      # Updates an existing order (quote or invoice) by ID.
      #
      # @param id [String, Integer]
      # @return [Printavo::Order]
      #
      # @example
      #   client.orders.update("99", nickname: "Rush Job", production_note: "Ships Friday")
      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION,
                               variables: { id: id.to_s, input: camelize_keys(input) })
        build_order(data['quoteUpdate'])
      end

      # Moves an order to a new status.
      #
      # @param id        [String, Integer] order (quote/invoice) ID
      # @param status_id [String, Integer] target status ID
      # @return [Printavo::Order]
      #
      # @example
      #   registry = client.statuses.registry
      #   client.orders.update_status("99", status_id: registry[:in_production].id)
      def update_status(id, status_id:)
        data = @graphql.mutate(UPDATE_STATUS_MUTATION,
                               variables: { parentId: id.to_s, statusId: status_id.to_s })
        build_order(data['statusUpdate'])
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

      # Normalizes mutation response: quoteCreate/quoteUpdate return `total`
      # rather than `totalPrice`. Map it so Order model accessors work unchanged.
      def build_order(attrs)
        return nil unless attrs

        normalized = attrs.dup
        normalized['totalPrice'] ||= attrs['total']
        Printavo::Order.new(normalized)
      end
    end
  end
end
