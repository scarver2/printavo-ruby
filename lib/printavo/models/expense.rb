# lib/printavo/models/expense.rb
# frozen_string_literal: true

module Printavo
  class Expense < Models::Base
    def id       = self['id']
    def name     = self['name']
    def amount   = self['amount']
    def category = self['category']
  end
end
