# lib/printavo/models/line_item_group_pricing.rb
# frozen_string_literal: true

module Printavo
  class LineItemGroupPricing < Models::Base
    def default_markup_percentage = self['defaultMarkupPercentage']
    def description               = self['description']
    def price                     = self['price']
    def signature                 = self['signature']
  end
end
