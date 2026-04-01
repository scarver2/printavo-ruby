# lib/printavo/enums/po_goods_status.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Receipt status of goods on a purchase order.
    module PoGoodsStatus
      CANCELLED = 'CANCELLED'
      PARTIAL   = 'PARTIAL'
      PENDING   = 'PENDING'
      RECEIVED  = 'RECEIVED'

      ALL = [CANCELLED, PARTIAL, PENDING, RECEIVED].freeze
    end
  end
end
