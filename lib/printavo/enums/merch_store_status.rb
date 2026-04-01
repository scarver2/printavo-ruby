# lib/printavo/enums/merch_store_status.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Publication status of a +MerchStore+.
    module MerchStoreStatus
      CLOSED = 'CLOSED'
      LIVE   = 'LIVE'

      ALL = [CLOSED, LIVE].freeze
    end
  end
end
