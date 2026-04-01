# lib/printavo/enums/transaction_category.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Category (direction) of a financial +Transaction+.
    module TransactionCategory
      PAYMENT = 'PAYMENT'
      REFUND  = 'REFUND'

      ALL = [PAYMENT, REFUND].freeze
    end
  end
end
