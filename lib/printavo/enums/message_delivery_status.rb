# lib/printavo/enums/message_delivery_status.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Delivery status for an email or text message sent via a +Thread+.
    module MessageDeliveryStatus
      BOUNCED   = 'BOUNCED'
      CLICKED   = 'CLICKED'
      DELIVERED = 'DELIVERED'
      ERROR     = 'ERROR'
      LINKED    = 'LINKED'
      OPENED    = 'OPENED'
      OTHER     = 'OTHER'
      PAY_FOR   = 'PAY_FOR'
      PENDING   = 'PENDING'
      REJECTED  = 'REJECTED'
      SENT      = 'SENT'

      ALL = [BOUNCED, CLICKED, DELIVERED, ERROR, LINKED, OPENED, OTHER, PAY_FOR, PENDING, REJECTED, SENT].freeze
    end
  end
end
