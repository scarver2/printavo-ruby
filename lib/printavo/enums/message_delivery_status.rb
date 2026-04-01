# lib/printavo/enums/message_delivery_status.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Delivery status for an email or text message sent via a +Thread+.
    module MessageDeliveryStatus
      BOUNCED   = 'BOUNCED'
      DELIVERED = 'DELIVERED'
      FAILED    = 'FAILED'
      PENDING   = 'PENDING'
      SENT      = 'SENT'

      ALL = [BOUNCED, DELIVERED, FAILED, PENDING, SENT].freeze
    end
  end
end
