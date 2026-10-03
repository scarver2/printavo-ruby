# lib/printavo/models/quote.rb
# frozen_string_literal: true

module Printavo
  class Quote < Order
    def total       = self['total']
    def total_price = total
    def updated_at  = dig('timestamps', 'updatedAt')

    def contact
      attrs = self['contact']
      Contact.new(attrs) if attrs
    end
  end
end
