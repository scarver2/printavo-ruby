# lib/printavo/models/line_item_price_receipt.rb
# frozen_string_literal: true

module Printavo
  class LineItemPriceReceipt < Models::Base
    def default_markup_percentage = self['defaultMarkupPercentage']
    def description               = self['description']
    def price                     = self['price']
    def signature                 = self['signature']
  end
end
