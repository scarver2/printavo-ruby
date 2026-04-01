# lib/printavo/enums/line_item_status.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Inventory / fulfillment status of a +LineItem+.
    module LineItemStatus
      ARRIVED            = 'arrived'
      ATTACHED_TO_PO     = 'attached_to_po'
      IN                 = 'in'
      NEED_ORDERING      = 'need_ordering'
      ORDERED            = 'ordered'
      PARTIALLY_RECEIVED = 'partially_received'
      RECEIVED           = 'received'

      ALL = [ARRIVED, ATTACHED_TO_PO, IN, NEED_ORDERING, ORDERED, PARTIALLY_RECEIVED, RECEIVED].freeze
    end
  end
end
