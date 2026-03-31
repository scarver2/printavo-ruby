# lib/printavo/models/approval_request.rb
# frozen_string_literal: true

module Printavo
  class ApprovalRequest < Models::Base
    def id         = self['id']
    def status     = self['status']
    def sent_at    = self['sentAt']
    def expires_at = self['expiresAt']
    def contact    = self['contact'] && Contact.new(self['contact'])
  end
end
