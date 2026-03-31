# lib/printavo/models/merch_store.rb
# frozen_string_literal: true

module Printavo
  class MerchStore < Models::Base
    def id      = self['id']
    def name    = self['name']
    def url     = self['url']
    def summary = self['summary']
  end
end
