# lib/printavo/models/contractor_profile.rb
# frozen_string_literal: true

module Printavo
  class ContractorProfile < Models::Base
    def id    = self['id']
    def name  = self['name']
    def email = self['email']
  end
end
