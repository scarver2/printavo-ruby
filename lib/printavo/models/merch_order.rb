# lib/printavo/models/merch_order.rb
# frozen_string_literal: true

module Printavo
  class MerchOrder < Models::Base
    def id       = self['id']
    def status   = self['status']
    def delivery = self['delivery']

    def contact
      attrs = self['contact']
      Contact.new(attrs) if attrs
    end
  end
end
