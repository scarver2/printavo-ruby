# lib/printavo/models/personalization.rb
# frozen_string_literal: true

module Printavo
  class Personalization < Models::Base
    def id              = self['id']
    def name            = self['name']
    def personalization = self['personalization']
  end
end
