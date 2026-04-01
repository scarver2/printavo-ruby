# lib/printavo/enums/order_payment_status.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Payment collection status on an order or invoice.
    module OrderPaymentStatus
      PAID    = 'PAID'
      PARTIAL = 'PARTIAL'
      UNPAID  = 'UNPAID'

      ALL = [PAID, PARTIAL, UNPAID].freeze
    end
  end
end
