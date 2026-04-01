# lib/printavo/enums/contact_sort_field.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Fields by which a contact list can be sorted.
    module ContactSortField
      CONTACT_EMAIL = 'CONTACT_EMAIL'
      CONTACT_NAME  = 'CONTACT_NAME'
      CUSTOMER_NAME = 'CUSTOMER_NAME'
      ORDER_COUNT   = 'ORDER_COUNT'

      ALL = [CONTACT_EMAIL, CONTACT_NAME, CUSTOMER_NAME, ORDER_COUNT].freeze
    end
  end
end
