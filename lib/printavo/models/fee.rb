# lib/printavo/models/fee.rb
# frozen_string_literal: true

module Printavo
  class Fee < Models::Base
    def id      = self['id']
    def name    = self['name']
    def amount  = self['amount']
    def taxable = self['taxable']
    def taxable? = !!self['taxable']
  end
end
