# lib/printavo/models/line_item_size_count.rb
# frozen_string_literal: true

module Printavo
  class LineItemSizeCount < Models::Base
    def count = self['count']
    def size  = self['size']
  end
end
