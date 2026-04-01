# lib/printavo/enums/merch_order_delivery_method.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # How a merch order will be fulfilled and delivered to the buyer.
    module MerchOrderDeliveryMethod
      DELIVERY = 'DELIVERY'
      PICKUP   = 'PICKUP'

      ALL = [DELIVERY, PICKUP].freeze
    end
  end
end
