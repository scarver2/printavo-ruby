# lib/printavo/enums/approval_request_status.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Possible values for the +ApprovalRequest+ status field.
    module ApprovalRequestStatus
      APPROVED   = 'approved'
      DECLINED   = 'declined'
      PENDING    = 'pending'
      REVOKED    = 'revoked'
      UNAPPROVED = 'unapproved'

      ALL = [APPROVED, DECLINED, PENDING, REVOKED, UNAPPROVED].freeze
    end
  end
end
