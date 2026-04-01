# lib/printavo/enums/approval_request_status.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Possible values for the +ApprovalRequest+ status field.
    module ApprovalRequestStatus
      APPROVED   = 'approved'
      PENDING    = 'pending'
      REVOKED    = 'revoked'
      UNAPPROVED = 'unapproved'

      ALL = [APPROVED, PENDING, REVOKED, UNAPPROVED].freeze
    end
  end
end
