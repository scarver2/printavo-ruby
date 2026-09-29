# lib/printavo/models/transaction.rb
# frozen_string_literal: true

module Printavo
  class Transaction < Models::Base
    def id               = self['id']
    def amount           = self['amount']
    def category         = self['category']
    def description      = self['description']
    def processing?      = !!self['processing']
    def transaction_date = self['transactionDate']
    def created_at       = dig('timestamps', 'createdAt') || self['createdAt']
    def updated_at       = dig('timestamps', 'updatedAt')

    # Retained for payloads produced by earlier API schemas.
    def kind = self['kind']
  end
end
