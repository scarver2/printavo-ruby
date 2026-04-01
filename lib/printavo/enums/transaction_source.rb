# lib/printavo/enums/transaction_source.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # How a +Transaction+ was initiated or processed.
    module TransactionSource
      CARD   = 'CARD'
      CASH   = 'CASH'
      CHECK  = 'CHECK'
      MANUAL = 'MANUAL'
      ONLINE = 'ONLINE'

      ALL = [CARD, CASH, CHECK, MANUAL, ONLINE].freeze
    end
  end
end
