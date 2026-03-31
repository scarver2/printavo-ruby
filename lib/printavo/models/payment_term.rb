# lib/printavo/models/payment_term.rb
# frozen_string_literal: true

module Printavo
  class PaymentTerm < Models::Base
    def id       = self['id']
    def name     = self['name']
    def net_days = self['netDays']
  end
end
