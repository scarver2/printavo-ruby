# lib/printavo/models/line_item_group.rb
# frozen_string_literal: true

module Printavo
  class LineItemGroup < Models::Base
    def id          = self['id']
    def name        = self['name']
    def description = self['description']
  end
end
