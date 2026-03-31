# lib/printavo/models/product.rb
# frozen_string_literal: true

module Printavo
  class Product < Models::Base
    def id          = self['id']
    def name        = self['name']
    def sku         = self['sku']
    def description = self['description']
  end
end
