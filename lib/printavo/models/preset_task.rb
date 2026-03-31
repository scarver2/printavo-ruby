# lib/printavo/models/preset_task.rb
# frozen_string_literal: true

module Printavo
  class PresetTask < Models::Base
    def id              = self['id']
    def body            = self['body']
    def due_offset_days = self['dueOffsetDays']
    def assignee        = self['assignee']
  end
end
