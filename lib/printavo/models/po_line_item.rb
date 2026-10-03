# lib/printavo/models/po_line_item.rb
# frozen_string_literal: true

module Printavo
  class PoLineItem < Models::Base
    def id          = self['id']
    def color       = self['color']
    def description = self['description']
    def item_number = self['itemNumber']
    def items       = self['items']
    def position    = self['position']
    def sizes       = Array(self['sizes']).map { |attributes| LineItemSizeCount.new(attributes) }

    def category
      attributes = self['category']
      Category.new(attributes) if attributes
    end

    def purchase_order
      attributes = self['purchaseOrder']
      PurchaseOrder.new(attributes) if attributes
    end
  end
end
