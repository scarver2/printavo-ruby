# lib/printavo/models/delivery_method.rb
# frozen_string_literal: true

module Printavo
  class DeliveryMethod < Models::Base
    def id   = self['id']
    def name = self['name']
  end
end
