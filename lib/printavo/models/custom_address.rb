# lib/printavo/models/custom_address.rb
# frozen_string_literal: true

module Printavo
  class CustomAddress < Models::Base
    def id      = self['id']
    def name    = self['name']
    def address = self['address']
    def city    = self['city']
    def state   = self['state']
    def zip     = self['zip']
  end
end
