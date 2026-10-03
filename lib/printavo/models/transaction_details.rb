# lib/printavo/models/transaction_details.rb
# frozen_string_literal: true

module Printavo
  class TransactionDetails < Models::Base
    def id                    = self['id']
    def amount                = self['amount']
    def category              = self['category']
    def card_type             = self['ccCardType']
    def card_last_four        = self['ccLastFour']
    def description           = self['description']
    def portal_transaction_id = self['portalTransactionId']
    def processing?           = self['processing']
    def transaction_date      = self['transactionDate']
  end
end
