# lib/printavo/models/imprint.rb
# frozen_string_literal: true

module Printavo
  class Imprint < Models::Base
    def id       = self['id']
    def name     = self['name']
    def position = self['position']
    def colors   = self['colors']
  end
end
