# lib/printavo/models/type_of_work.rb
# frozen_string_literal: true

module Printavo
  class TypeOfWork < Models::Base
    def id   = self['id']
    def name = self['name']
  end
end
