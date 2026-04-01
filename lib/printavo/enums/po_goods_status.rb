# lib/printavo/enums/po_goods_status.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Receipt status of goods on a purchase order.
    module PoGoodsStatus
      ARRIVED            = 'arrived'
      NOT_ORDERED        = 'not_ordered'
      ORDERED            = 'ordered'
      PARTIALLY_RECEIVED = 'partially_received'
      RECEIVED           = 'received'

      ALL = [ARRIVED, NOT_ORDERED, ORDERED, PARTIALLY_RECEIVED, RECEIVED].freeze
    end
  end
end
