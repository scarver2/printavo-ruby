# lib/printavo/models/category.rb
# frozen_string_literal: true

module Printavo
  class Category < Models::Base
    def id   = self['id']
    def name = self['name']
  end
end
