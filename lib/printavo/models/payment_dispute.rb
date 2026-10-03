# lib/printavo/models/payment_dispute.rb
# frozen_string_literal: true

require_relative 'transaction'

module Printavo
  class PaymentDispute < Transaction
    def status = self['status']
  end
end
