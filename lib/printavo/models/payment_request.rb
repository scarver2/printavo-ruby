# lib/printavo/models/payment_request.rb
# frozen_string_literal: true

module Printavo
  class PaymentRequest < Models::Base
    def id      = self['id']
    def amount  = self['amount']
    def sent_at = self['sentAt']
    def paid_at = self['paidAt']
    def details = self['details']
  end
end
