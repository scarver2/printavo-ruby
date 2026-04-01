# lib/printavo/enums/task_sort_field.rb
# frozen_string_literal: true

module Printavo
  module Enums
    # Fields by which a task list can be sorted.
    module TaskSortField
      CREATED_AT = 'CREATED_AT'
      DUE_AT     = 'DUE_AT'

      ALL = [CREATED_AT, DUE_AT].freeze
    end
  end
end
