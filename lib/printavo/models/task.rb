# lib/printavo/models/task.rb
# frozen_string_literal: true

module Printavo
  class Task < Models::Base
    def id           = self['id']
    def body         = self['body']
    def due_at       = self['dueAt']
    def completed_at = self['completedAt']
    def completed?   = !completed_at.nil?
    def assignee     = self['assignee']
  end
end
