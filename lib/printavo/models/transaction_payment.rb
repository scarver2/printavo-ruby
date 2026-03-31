# lib/printavo/models/transaction_payment.rb
# frozen_string_literal: true

module Printavo
  class TransactionPayment < Models::Base
    def id             = self['id']
    def amount         = self['amount']
    def payment_method = self['paymentMethod']
    def paid_at        = self['paidAt']
    def note           = self['note']
  end
end
