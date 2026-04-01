# lib/printavo/models/customer.rb
# frozen_string_literal: true

module Printavo
  class Customer < Models::Base
    def id         = self['id']
    def first_name = self['firstName']
    def last_name  = self['lastName']
    def email      = self['email']
    def phone      = self['phone']
    def company    = self['company']
    def created_at = self['createdAt']
    def updated_at = self['updatedAt']

    def full_name
      [first_name, last_name].compact.join(' ').strip
    end
  end
end
