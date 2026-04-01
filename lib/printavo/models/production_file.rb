# lib/printavo/models/production_file.rb
# frozen_string_literal: true

module Printavo
  class ProductionFile < Models::Base
    def id         = self['id']
    def url        = self['url']
    def filename   = self['filename']
    def created_at = self['createdAt']
  end
end
