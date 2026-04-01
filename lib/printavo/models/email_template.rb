# lib/printavo/models/email_template.rb
# frozen_string_literal: true

module Printavo
  class EmailTemplate < Models::Base
    def id      = self['id']
    def name    = self['name']
    def subject = self['subject']
    def body    = self['body']
  end
end
