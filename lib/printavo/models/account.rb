# lib/printavo/models/account.rb
# frozen_string_literal: true

module Printavo
  class Account < Models::Base
    def id            = self['id']
    def company_name  = self['companyName']
    def company_email = self['companyEmail']
    def phone         = self['phone']
    def website       = self['website']
    def logo_url      = self['logoUrl']
    def locale        = self['locale']
  end
end
