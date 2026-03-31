# lib/printavo/resources/expenses.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class Expenses < Base
      ALL_QUERY       = File.read(File.join(__dir__, '../graphql/expenses/all.graphql')).freeze
      FIND_QUERY      = File.read(File.join(__dir__, '../graphql/expenses/find.graphql')).freeze
      CREATE_MUTATION = File.read(File.join(__dir__, '../graphql/expenses/create.graphql')).freeze
      UPDATE_MUTATION = File.read(File.join(__dir__, '../graphql/expenses/update.graphql')).freeze

      def all(order_id:, first: 25, after: nil)
        fetch_page(order_id: order_id, first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Expense.new(data['expense'])
      end

      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: camelize_keys(input) })
        Printavo::Expense.new(data['expenseCreate'])
      end

      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION, variables: { id: id.to_s, input: camelize_keys(input) })
        Printavo::Expense.new(data['expenseUpdate'])
      end

      private

      def fetch_page(order_id:, first: 25, after: nil, **)
        data = @graphql.query(
          ALL_QUERY,
          variables: { orderId: order_id.to_s, first: first, after: after }
        )
        nodes = data['order']['expenses']['nodes'].map { |attrs| Printavo::Expense.new(attrs) }
        page_info = data['order']['expenses']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
