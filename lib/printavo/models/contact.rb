# lib/printavo/models/contact.rb
# frozen_string_literal: true

module Printavo
  class Contact < Models::Base
    def id         = self['id']
    def first_name = self['firstName']
    def last_name  = self['lastName']
    def email      = self['email']
    def phone      = self['phone']
    def fax        = self['fax']
    def created_at = self['createdAt']
    def updated_at = self['updatedAt']

    def full_name
      self['fullName'] || [first_name, last_name].compact.join(' ').strip
    end
  end
end
