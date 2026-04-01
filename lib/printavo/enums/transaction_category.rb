# lib/printavo/enums/transaction_category.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Payment method category for a +Transaction+.
    module TransactionCategory
      BANK_TRANSFER = 'BANK_TRANSFER'
      CASH          = 'CASH'
      CHECK         = 'CHECK'
      CREDIT_CARD   = 'CREDIT_CARD'
      ECHECK        = 'ECHECK'
      OTHER         = 'OTHER'

      ALL = [BANK_TRANSFER, CASH, CHECK, CREDIT_CARD, ECHECK, OTHER].freeze
    end
  end
end
