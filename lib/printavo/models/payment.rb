# lib/printavo/models/payment.rb
# frozen_string_literal: true

require_relative 'transaction'

module Printavo
  class Payment < Transaction
    def payment_method = self['paymentMethod']
    def paid_at        = self['paidAt']
    def source = self['source']

    def disputes
      nodes = dig('disputes', 'nodes') || self['disputes']
      Array(nodes).map { |attributes| PaymentDispute.new(attributes) }
    end
  end
end
