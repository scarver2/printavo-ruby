# lib/printavo/enums/task_sort_field.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Fields by which a task list can be sorted.
    module TaskSortField
      BODY       = 'BODY'
      CREATED_AT = 'CREATED_AT'
      DUE_AT     = 'DUE_AT'
      UPDATED_AT = 'UPDATED_AT'

      ALL = [BODY, CREATED_AT, DUE_AT, UPDATED_AT].freeze
    end
  end
end
