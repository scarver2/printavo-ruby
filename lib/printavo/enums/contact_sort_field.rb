# lib/printavo/enums/contact_sort_field.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Fields by which a contact list can be sorted.
    module ContactSortField
      CREATED_AT = 'CREATED_AT'
      EMAIL      = 'EMAIL'
      FIRST_NAME = 'FIRST_NAME'
      LAST_NAME  = 'LAST_NAME'
      UPDATED_AT = 'UPDATED_AT'

      ALL = [CREATED_AT, EMAIL, FIRST_NAME, LAST_NAME, UPDATED_AT].freeze
    end
  end
end
