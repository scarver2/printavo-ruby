# lib/printavo/enums/merch_order_status.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Lifecycle status of a +MerchOrder+.
    module MerchOrderStatus
      CANCELLED  = 'CANCELLED'
      COMPLETE   = 'COMPLETE'
      PENDING    = 'PENDING'
      PROCESSING = 'PROCESSING'

      ALL = [CANCELLED, COMPLETE, PENDING, PROCESSING].freeze
    end
  end
end
