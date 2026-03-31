# lib/printavo/resources/tasks.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class Tasks < Base
      ALL_QUERY       = File.read(File.join(__dir__, '../graphql/tasks/all.graphql')).freeze
      FIND_QUERY      = File.read(File.join(__dir__, '../graphql/tasks/find.graphql')).freeze
      CREATE_MUTATION = File.read(File.join(__dir__, '../graphql/tasks/create.graphql')).freeze
      UPDATE_MUTATION = File.read(File.join(__dir__, '../graphql/tasks/update.graphql')).freeze
      DELETE_MUTATION = File.read(File.join(__dir__, '../graphql/tasks/delete.graphql')).freeze

      def all(first: 25, after: nil)
        fetch_page(first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Task.new(data['task'])
      end

      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: camelize_keys(input) })
        Printavo::Task.new(data['taskCreate'])
      end

      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION,
                               variables: { id: id.to_s, input: camelize_keys(input) })
        Printavo::Task.new(data['taskUpdate'])
      end

      # Marks a task complete by setting completedAt to the current time.
      def complete(id)
        require 'time'
        update(id, completed_at: Time.now.utc.iso8601)
      end

      # Deletes a task. Raises on failure; returns nil on success.
      def delete(id)
        @graphql.mutate(DELETE_MUTATION, variables: { id: id.to_s })
        nil
      end

      private

      def fetch_page(first: 25, after: nil, **)
        data = @graphql.query(ALL_QUERY, variables: { first: first, after: after })
        nodes = data['tasks']['nodes'].map { |attrs| Printavo::Task.new(attrs) }
        page_info = data['tasks']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
