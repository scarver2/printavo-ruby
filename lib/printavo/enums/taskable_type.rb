# lib/printavo/enums/taskable_type.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Record types to which a +Task+ can be attached.
    module TaskableType
      CUSTOMER = 'CUSTOMER'
      INVOICE  = 'INVOICE'
      QUOTE    = 'QUOTE'

      ALL = [CUSTOMER, INVOICE, QUOTE].freeze
    end
  end
end
