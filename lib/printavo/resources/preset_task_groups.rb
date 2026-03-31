# lib/printavo/resources/preset_task_groups.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class PresetTaskGroups < Base
      ALL_QUERY       = File.read(File.join(__dir__, '../graphql/preset_task_groups/all.graphql')).freeze
      FIND_QUERY      = File.read(File.join(__dir__, '../graphql/preset_task_groups/find.graphql')).freeze
      CREATE_MUTATION = File.read(File.join(__dir__, '../graphql/preset_task_groups/create.graphql')).freeze
      UPDATE_MUTATION = File.read(File.join(__dir__, '../graphql/preset_task_groups/update.graphql')).freeze
      DELETE_MUTATION = File.read(File.join(__dir__, '../graphql/preset_task_groups/delete.graphql')).freeze
      APPLY_MUTATION  = File.read(File.join(__dir__, '../graphql/preset_task_groups/apply.graphql')).freeze

      def all(first: 25, after: nil)
        fetch_page(first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::PresetTaskGroup.new(data['presetTaskGroup'])
      end

      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: camelize_keys(input) })
        Printavo::PresetTaskGroup.new(data['presetTaskGroupCreate'])
      end

      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION, variables: { id: id.to_s, input: camelize_keys(input) })
        Printavo::PresetTaskGroup.new(data['presetTaskGroupUpdate'])
      end

      def delete(id)
        @graphql.mutate(DELETE_MUTATION, variables: { id: id.to_s })
        nil
      end

      def apply(id, order_id:)
        data = @graphql.mutate(APPLY_MUTATION, variables: { id: id.to_s, orderId: order_id.to_s })
        data['presetTaskGroupApply'].map { |attrs| Printavo::Task.new(attrs) }
      end

      private

      def fetch_page(first: 25, after: nil, **)
        data = @graphql.query(ALL_QUERY, variables: { first: first, after: after })
        nodes     = data['presetTaskGroups']['nodes'].map { |attrs| Printavo::PresetTaskGroup.new(attrs) }
        page_info = data['presetTaskGroups']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
