# lib/printavo/enums/taskable_type.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Order types to which a +Task+ can be attached.
    module TaskableType
      INVOICE = 'INVOICE'
      QUOTE   = 'QUOTE'

      ALL = [INVOICE, QUOTE].freeze
    end
  end
end
