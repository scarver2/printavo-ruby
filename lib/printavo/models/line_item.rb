# lib/printavo/models/line_item.rb
# frozen_string_literal: true

module Printavo
  class LineItem < Models::Base
    def id                = self['id']
    def color             = self['color']
    def description       = self['description']
    def item_number       = self['itemNumber']
    def items             = self['items']
    def markup_percentage = self['markupPercentage']
    def merch?            = !!self['merch']
    def position          = self['position']
    def price             = self['price']
    def product_status    = self['productStatus']
    def sizes             = Array(self['sizes']).map { |attributes| LineItemSizeCount.new(attributes) }
    def taxed             = self['taxed']
    def taxed?            = !!self['taxed']

    # Legacy accessors remain available for payloads recorded against older
    # Printavo schemas.
    def name     = self['name']
    def quantity = self['quantity']
    def taxable  = self['taxable'].nil? ? taxed : self['taxable']
    def taxable? = !!taxable

    def category
      attributes = self['category']
      Category.new(attributes) if attributes
    end

    def personalizations
      Array(self['personalizations']).map { |attributes| Personalization.new(attributes) }
    end

    def po_line_item
      attributes = self['poLineItem']
      PoLineItem.new(attributes) if attributes
    end

    def price_receipt
      attributes = self['priceReceipt']
      LineItemPriceReceipt.new(attributes) if attributes
    end

    def product
      attributes = self['product']
      Product.new(attributes) if attributes
    end
  end
end
