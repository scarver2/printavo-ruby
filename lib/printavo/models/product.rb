# lib/printavo/models/product.rb
# frozen_string_literal: true

module Printavo
  class Product < Models::Base
    def id          = self['id']
    def brand       = self['brand']
    def color       = self['color']
    def description = self['description']
    def item_number = self['itemNumber']

    # Retained for payloads produced by earlier API schemas.
    def name = self['name']
    def sku  = self['sku']
  end
end
