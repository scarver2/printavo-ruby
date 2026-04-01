# lib/printavo/enums/payment_request_status.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Lifecycle status of a +PaymentRequest+.
    module PaymentRequestStatus
      ARCHIVED = 'ARCHIVED'
      CLOSED   = 'CLOSED'
      OPEN     = 'OPEN'

      ALL = [ARCHIVED, CLOSED, OPEN].freeze
    end
  end
end
