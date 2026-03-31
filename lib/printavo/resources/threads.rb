# lib/printavo/resources/threads.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class Threads < Base
      ALL_QUERY                  = File.read(File.join(__dir__, '../graphql/threads/all.graphql')).freeze
      FIND_QUERY                 = File.read(File.join(__dir__, '../graphql/threads/find.graphql')).freeze
      UPDATE_MUTATION            = File.read(File.join(__dir__, '../graphql/threads/update.graphql')).freeze
      EMAIL_MESSAGE_CREATE_MUTATION =
        File.read(File.join(__dir__, '../graphql/threads/email_message_create.graphql')).freeze

      def all(order_id:, first: 25, after: nil)
        fetch_page(order_id: order_id, first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Thread.new(data['thread'])
      end

      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION,
                               variables: { id: id.to_s, input: camelize_keys(input) })
        Printavo::Thread.new(data['threadUpdate'])
      end

      # Sends an email message on a thread. Returns the raw message hash.
      # A dedicated EmailMessage model is planned for a future version.
      def email_message_create(**input)
        data = @graphql.mutate(EMAIL_MESSAGE_CREATE_MUTATION,
                               variables: { input: camelize_keys(input) })
        data['emailMessageCreate']
      end

      private

      def fetch_page(order_id:, first: 25, after: nil, **)
        data = @graphql.query(
          ALL_QUERY,
          variables: { orderId: order_id.to_s, first: first, after: after }
        )
        nodes = data['order']['threads']['nodes'].map { |attrs| Printavo::Thread.new(attrs) }
        page_info = data['order']['threads']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
