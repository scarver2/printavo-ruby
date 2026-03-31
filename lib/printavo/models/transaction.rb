# lib/printavo/models/transaction.rb
# frozen_string_literal: true

module Printavo
  class Transaction < Models::Base
    def id         = self['id']
    def amount     = self['amount']
    def kind       = self['kind']
    def created_at = self['createdAt']
  end
end
