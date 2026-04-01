# lib/printavo/enums/payment_dispute_status_field.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Status of a payment dispute (chargeback).
    module PaymentDisputeStatusField
      DISPUTE_INITIATED = 'DISPUTE_INITIATED'
      DISPUTE_IN_REVIEW = 'DISPUTE_IN_REVIEW'
      DISPUTE_LOST      = 'DISPUTE_LOST'
      DISPUTE_WON       = 'DISPUTE_WON'
      RETRIEVAL_REQUEST = 'RETRIEVAL_REQUEST'

      ALL = [DISPUTE_INITIATED, DISPUTE_IN_REVIEW, DISPUTE_LOST, DISPUTE_WON, RETRIEVAL_REQUEST].freeze
    end
  end
end
