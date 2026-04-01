# lib/printavo/enums/merch_store_status.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Publication status of a +MerchStore+.
    module MerchStoreStatus
      ACTIVE   = 'ACTIVE'
      ARCHIVED = 'ARCHIVED'
      CLOSED   = 'CLOSED'

      ALL = [ACTIVE, ARCHIVED, CLOSED].freeze
    end
  end
end
