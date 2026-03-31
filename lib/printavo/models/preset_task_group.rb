# lib/printavo/models/preset_task_group.rb
# frozen_string_literal: true

module Printavo
  class PresetTaskGroup < Models::Base
    def id    = self['id']
    def name  = self['name']
    def tasks = Array(self['tasks']).map { |attrs| PresetTask.new(attrs) }
  end
end
