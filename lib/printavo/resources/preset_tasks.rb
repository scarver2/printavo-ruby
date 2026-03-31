# lib/printavo/resources/preset_tasks.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class PresetTasks < Base
      FIND_QUERY      = File.read(File.join(__dir__, '../graphql/preset_tasks/find.graphql')).freeze
      CREATE_MUTATION = File.read(File.join(__dir__, '../graphql/preset_tasks/create.graphql')).freeze
      UPDATE_MUTATION = File.read(File.join(__dir__, '../graphql/preset_tasks/update.graphql')).freeze
      DELETE_MUTATION = File.read(File.join(__dir__, '../graphql/preset_tasks/delete.graphql')).freeze

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::PresetTask.new(data['presetTask'])
      end

      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: camelize_keys(input) })
        Printavo::PresetTask.new(data['presetTaskCreate'])
      end

      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION, variables: { id: id.to_s, input: camelize_keys(input) })
        Printavo::PresetTask.new(data['presetTaskUpdate'])
      end

      def delete(id)
        @graphql.mutate(DELETE_MUTATION, variables: { id: id.to_s })
        nil
      end
    end
  end
end
