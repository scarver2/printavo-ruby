# lib/printavo/enums/payment_request_status.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Lifecycle status of a +PaymentRequest+.
    module PaymentRequestStatus
      CANCELLED = 'CANCELLED'
      PAID      = 'PAID'
      SENT      = 'SENT'

      ALL = [CANCELLED, PAID, SENT].freeze
    end
  end
end
