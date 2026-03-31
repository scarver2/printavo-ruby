# lib/printavo/models/pricing_matrix.rb
# frozen_string_literal: true

module Printavo
  class PricingMatrix < Models::Base
    def id   = self['id']
    def name = self['name']
  end
end
