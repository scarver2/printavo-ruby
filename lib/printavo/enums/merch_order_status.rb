# lib/printavo/enums/merch_order_status.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Fulfillment status of a +MerchOrder+.
    module MerchOrderStatus
      FULFILLED   = 'FULFILLED'
      UNFULFILLED = 'UNFULFILLED'

      ALL = [FULFILLED, UNFULFILLED].freeze
    end
  end
end
