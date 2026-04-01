# lib/printavo/enums/payment_dispute_status_field.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Status of a payment dispute (chargeback).
    module PaymentDisputeStatusField
      LOST           = 'LOST'
      NEEDS_RESPONSE = 'NEEDS_RESPONSE'
      RESOLVED       = 'RESOLVED'
      UNDER_REVIEW   = 'UNDER_REVIEW'
      WON            = 'WON'

      ALL = [LOST, NEEDS_RESPONSE, RESOLVED, UNDER_REVIEW, WON].freeze
    end
  end
end
