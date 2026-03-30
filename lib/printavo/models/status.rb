# lib/printavo/models/status.rb
# frozen_string_literal: true

module Printavo
  class Status < Models::Base
    def id    = self['id']
    def name  = self['name']
    def color = self['color']

    # Returns a normalized symbol key matching Order#status_key.
    # e.g. "In Production" => :in_production
    def key
      return nil if name.nil?

      name.downcase.gsub(/\s+/, '_').to_sym
    end
  end
end
