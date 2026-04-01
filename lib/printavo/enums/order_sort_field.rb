# lib/printavo/enums/order_sort_field.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Fields by which an order or invoice list can be sorted.
    module OrderSortField
      CUSTOMER_DUE_AT = 'CUSTOMER_DUE_AT'
      CUSTOMER_NAME   = 'CUSTOMER_NAME'
      OWNER           = 'OWNER'
      STATUS          = 'STATUS'
      TOTAL           = 'TOTAL'
      VISUAL_ID       = 'VISUAL_ID'

      ALL = [CUSTOMER_DUE_AT, CUSTOMER_NAME, OWNER, STATUS, TOTAL, VISUAL_ID].freeze
    end
  end
end
