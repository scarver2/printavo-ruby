# lib/printavo/enums/order_sort_field.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Fields by which an order or invoice list can be sorted.
    module OrderSortField
      CREATED_AT       = 'CREATED_AT'
      CUSTOMER_DUE_AT  = 'CUSTOMER_DUE_AT'
      DUE_AT           = 'DUE_AT'
      UPDATED_AT       = 'UPDATED_AT'
      VISUAL_ID        = 'VISUAL_ID'

      ALL = [CREATED_AT, CUSTOMER_DUE_AT, DUE_AT, UPDATED_AT, VISUAL_ID].freeze
    end
  end
end
