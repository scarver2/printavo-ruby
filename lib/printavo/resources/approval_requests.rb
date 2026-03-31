# lib/printavo/resources/approval_requests.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class ApprovalRequests < Base
      ALL_QUERY          = File.read(File.join(__dir__, '../graphql/approval_requests/all.graphql')).freeze
      FIND_QUERY         = File.read(File.join(__dir__, '../graphql/approval_requests/find.graphql')).freeze
      CREATE_MUTATION    = File.read(File.join(__dir__, '../graphql/approval_requests/create.graphql')).freeze
      APPROVE_MUTATION   = File.read(File.join(__dir__, '../graphql/approval_requests/approve.graphql')).freeze
      REVOKE_MUTATION    = File.read(File.join(__dir__, '../graphql/approval_requests/revoke.graphql')).freeze
      UNAPPROVE_MUTATION = File.read(File.join(__dir__, '../graphql/approval_requests/unapprove.graphql')).freeze

      def all(order_id:, first: 25, after: nil)
        fetch_page(order_id: order_id, first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::ApprovalRequest.new(data['approvalRequest'])
      end

      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: camelize_keys(input) })
        Printavo::ApprovalRequest.new(data['approvalRequestCreate'])
      end

      def approve(id)
        data = @graphql.mutate(APPROVE_MUTATION, variables: { id: id.to_s })
        Printavo::ApprovalRequest.new(data['approvalRequestApprove'])
      end

      def revoke(id)
        data = @graphql.mutate(REVOKE_MUTATION, variables: { id: id.to_s })
        Printavo::ApprovalRequest.new(data['approvalRequestRevoke'])
      end

      def unapprove(id)
        data = @graphql.mutate(UNAPPROVE_MUTATION, variables: { id: id.to_s })
        Printavo::ApprovalRequest.new(data['approvalRequestUnapprove'])
      end

      private

      def fetch_page(order_id:, first: 25, after: nil, **)
        data = @graphql.query(
          ALL_QUERY,
          variables: { orderId: order_id.to_s, first: first, after: after }
        )
        nodes     = data['order']['approvalRequests']['nodes'].map { |attrs| Printavo::ApprovalRequest.new(attrs) }
        page_info = data['order']['approvalRequests']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
