# lib/printavo/resources/transaction_payments.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class TransactionPayments < Base
      CREATE_MUTATION = File.read(File.join(__dir__, '../graphql/transaction_payments/create.graphql')).freeze
      UPDATE_MUTATION = File.read(File.join(__dir__, '../graphql/transaction_payments/update.graphql')).freeze
      DELETE_MUTATION = File.read(File.join(__dir__, '../graphql/transaction_payments/delete.graphql')).freeze

      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: camelize_keys(input) })
        Printavo::TransactionPayment.new(data['transactionPaymentCreate'])
      end

      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION,
                               variables: { id: id.to_s, input: camelize_keys(input) })
        Printavo::TransactionPayment.new(data['transactionPaymentUpdate'])
      end

      # Deletes a transaction payment. Raises on failure; returns nil on success.
      def delete(id)
        @graphql.mutate(DELETE_MUTATION, variables: { id: id.to_s })
        nil
      end
    end
  end
end
