# lib/printavo/models/payment.rb
# frozen_string_literal: true

module Printavo
  class Payment < Models::Base
    def id             = self['id']
    def amount         = self['amount']
    def payment_method = self['paymentMethod']
    def paid_at        = self['paidAt']
  end
end
