# lib/printavo/enums/status_type.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Which order type a +Status+ applies to.
    module StatusType
      INVOICE = 'INVOICE'
      QUOTE   = 'QUOTE'

      ALL = [INVOICE, QUOTE].freeze
    end
  end
end
