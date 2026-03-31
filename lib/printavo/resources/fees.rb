# lib/printavo/resources/fees.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class Fees < Base
      ALL_QUERY        = File.read(File.join(__dir__, '../graphql/fees/all.graphql')).freeze
      FIND_QUERY       = File.read(File.join(__dir__, '../graphql/fees/find.graphql')).freeze
      CREATE_MUTATION  = File.read(File.join(__dir__, '../graphql/fees/create.graphql')).freeze
      CREATES_MUTATION = File.read(File.join(__dir__, '../graphql/fees/creates.graphql')).freeze
      UPDATE_MUTATION  = File.read(File.join(__dir__, '../graphql/fees/update.graphql')).freeze
      UPDATES_MUTATION = File.read(File.join(__dir__, '../graphql/fees/updates.graphql')).freeze
      DELETE_MUTATION  = File.read(File.join(__dir__, '../graphql/fees/delete.graphql')).freeze
      DELETES_MUTATION = File.read(File.join(__dir__, '../graphql/fees/deletes.graphql')).freeze

      def all(order_id:, first: 25, after: nil)
        fetch_page(order_id: order_id, first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Fee.new(data['fee'])
      end

      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: camelize_keys(input) })
        Printavo::Fee.new(data['feeCreate'])
      end

      def creates(inputs)
        data = @graphql.mutate(CREATES_MUTATION, variables: { inputs: inputs.map { |i| camelize_keys(i) } })
        data['feeCreates'].map { |attrs| Printavo::Fee.new(attrs) }
      end

      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION, variables: { id: id.to_s, input: camelize_keys(input) })
        Printavo::Fee.new(data['feeUpdate'])
      end

      def updates(inputs)
        data = @graphql.mutate(UPDATES_MUTATION, variables: { inputs: inputs.map { |i| camelize_keys(i) } })
        data['feeUpdates'].map { |attrs| Printavo::Fee.new(attrs) }
      end

      def delete(id)
        @graphql.mutate(DELETE_MUTATION, variables: { id: id.to_s })
        nil
      end

      def deletes(ids)
        @graphql.mutate(DELETES_MUTATION, variables: { ids: ids.map(&:to_s) })
        nil
      end

      private

      def fetch_page(order_id:, first: 25, after: nil, **)
        data = @graphql.query(
          ALL_QUERY,
          variables: { orderId: order_id.to_s, first: first, after: after }
        )
        nodes = data['order']['fees']['nodes'].map { |attrs| Printavo::Fee.new(attrs) }
        page_info = data['order']['fees']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
