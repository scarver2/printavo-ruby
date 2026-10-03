# lib/printavo/models/purchase_order.rb
# frozen_string_literal: true

module Printavo
  class PurchaseOrder < Models::Base
    def id = self['id']
    def goods_status = self['goodsStatus']
    def note = self['note']
    def visual_po_id = self['visualPoId']

    def vendor
      attributes = self['vendor']
      Vendor.new(attributes) if attributes
    end
  end
end
