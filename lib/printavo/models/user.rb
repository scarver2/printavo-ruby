# lib/printavo/models/user.rb
# frozen_string_literal: true

module Printavo
  class User < Models::Base
    def id         = self['id']
    def first_name = self['firstName']
    def last_name  = self['lastName']
    def email      = self['email']
    def full_name  = "#{first_name} #{last_name}".strip
  end
end
