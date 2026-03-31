# lib/printavo/models/line_item.rb
# frozen_string_literal: true

module Printavo
  class LineItem < Models::Base
    def id       = self['id']
    def name     = self['name']
    def quantity = self['quantity']
    def price    = self['price']
    def taxable  = self['taxable']
    def taxable? = !!self['taxable']
  end
end
