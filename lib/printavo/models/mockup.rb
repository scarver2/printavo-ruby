# lib/printavo/models/mockup.rb
# frozen_string_literal: true

module Printavo
  class Mockup < Models::Base
    def id         = self['id']
    def url        = self['url']
    def position   = self['position']
    def created_at = self['createdAt']
  end
end
