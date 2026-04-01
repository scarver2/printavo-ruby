# lib/printavo/models/vendor.rb
# frozen_string_literal: true

module Printavo
  class Vendor < Models::Base
    def id    = self['id']
    def name  = self['name']
    def email = self['email']
    def phone = self['phone']
  end
end
