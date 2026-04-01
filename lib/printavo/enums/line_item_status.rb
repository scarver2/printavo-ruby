# lib/printavo/enums/line_item_status.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Possible status values for a +LineItem+.
    module LineItemStatus
      ACTIVE    = 'ACTIVE'
      CANCELLED = 'CANCELLED'

      ALL = [ACTIVE, CANCELLED].freeze
    end
  end
end
