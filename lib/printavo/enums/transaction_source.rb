# lib/printavo/enums/transaction_source.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # How a +Transaction+ was initiated or processed.
    module TransactionSource
      MANUAL    = 'MANUAL'
      PROCESSOR = 'PROCESSOR'

      ALL = [MANUAL, PROCESSOR].freeze
    end
  end
end
