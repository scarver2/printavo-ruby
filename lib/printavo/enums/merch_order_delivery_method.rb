# lib/printavo/enums/merch_order_delivery_method.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # How a merch order will be fulfilled and delivered to the buyer.
    module MerchOrderDeliveryMethod
      LOCAL_DELIVERY = 'LOCAL_DELIVERY'
      PICKUP         = 'PICKUP'
      SHIP           = 'SHIP'

      ALL = [LOCAL_DELIVERY, PICKUP, SHIP].freeze
    end
  end
end
