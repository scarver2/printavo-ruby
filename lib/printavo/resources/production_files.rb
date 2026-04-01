# lib/printavo/resources/production_files.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class ProductionFiles < Base
      ALL_QUERY        = File.read(File.join(__dir__, '../graphql/production_files/all.graphql')).freeze
      FIND_QUERY       = File.read(File.join(__dir__, '../graphql/production_files/find.graphql')).freeze
      CREATE_MUTATION  = File.read(File.join(__dir__, '../graphql/production_files/create.graphql')).freeze
      CREATES_MUTATION = File.read(File.join(__dir__, '../graphql/production_files/creates.graphql')).freeze
      DELETE_MUTATION  = File.read(File.join(__dir__, '../graphql/production_files/delete.graphql')).freeze
      DELETES_MUTATION = File.read(File.join(__dir__, '../graphql/production_files/deletes.graphql')).freeze

      def all(order_id:, first: 25, after: nil)
        fetch_page(order_id: order_id, first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::ProductionFile.new(data['productionFile'])
      end

      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: camelize_keys(input) })
        Printavo::ProductionFile.new(data['productionFileCreate'])
      end

      def creates(inputs)
        data = @graphql.mutate(CREATES_MUTATION, variables: { inputs: inputs.map { |i| camelize_keys(i) } })
        data['productionFileCreates'].map { |attrs| Printavo::ProductionFile.new(attrs) }
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
        nodes     = data['order']['productionFiles']['nodes'].map { |attrs| Printavo::ProductionFile.new(attrs) }
        page_info = data['order']['productionFiles']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
