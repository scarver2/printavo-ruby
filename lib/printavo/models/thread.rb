# lib/printavo/models/thread.rb
# frozen_string_literal: true

module Printavo
  class Thread < Models::Base
    def id         = self['id']
    def subject    = self['subject']
    def created_at = self['createdAt']
    def updated_at = self['updatedAt']
  end
end
