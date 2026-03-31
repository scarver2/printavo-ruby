# lib/printavo/resources/imprints.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class Imprints < Base
      ALL_QUERY               = File.read(File.join(__dir__, '../graphql/imprints/all.graphql')).freeze
      FIND_QUERY              = File.read(File.join(__dir__, '../graphql/imprints/find.graphql')).freeze
      CREATE_MUTATION         = File.read(File.join(__dir__, '../graphql/imprints/create.graphql')).freeze
      CREATES_MUTATION        = File.read(File.join(__dir__, '../graphql/imprints/creates.graphql')).freeze
      UPDATE_MUTATION         = File.read(File.join(__dir__, '../graphql/imprints/update.graphql')).freeze
      UPDATES_MUTATION        = File.read(File.join(__dir__, '../graphql/imprints/updates.graphql')).freeze
      DELETE_MUTATION         = File.read(File.join(__dir__, '../graphql/imprints/delete.graphql')).freeze
      DELETES_MUTATION        = File.read(File.join(__dir__, '../graphql/imprints/deletes.graphql')).freeze
      MOCKUP_CREATE_MUTATION  = File.read(File.join(__dir__, '../graphql/imprints/mockup_create.graphql')).freeze
      MOCKUP_CREATES_MUTATION = File.read(File.join(__dir__, '../graphql/imprints/mockup_creates.graphql')).freeze

      def all(line_item_group_id:, first: 25, after: nil)
        fetch_page(line_item_group_id: line_item_group_id, first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Imprint.new(data['imprint'])
      end

      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: camelize_keys(input) })
        Printavo::Imprint.new(data['imprintCreate'])
      end

      def creates(inputs)
        data = @graphql.mutate(CREATES_MUTATION, variables: { inputs: inputs.map { |i| camelize_keys(i) } })
        data['imprintCreates'].map { |attrs| Printavo::Imprint.new(attrs) }
      end

      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION, variables: { id: id.to_s, input: camelize_keys(input) })
        Printavo::Imprint.new(data['imprintUpdate'])
      end

      def updates(inputs)
        data = @graphql.mutate(UPDATES_MUTATION, variables: { inputs: inputs.map { |i| camelize_keys(i) } })
        data['imprintUpdates'].map { |attrs| Printavo::Imprint.new(attrs) }
      end

      def delete(id)
        @graphql.mutate(DELETE_MUTATION, variables: { id: id.to_s })
        nil
      end

      def deletes(ids)
        @graphql.mutate(DELETES_MUTATION, variables: { ids: ids.map(&:to_s) })
        nil
      end

      def mockup_create(**input)
        data = @graphql.mutate(MOCKUP_CREATE_MUTATION, variables: { input: camelize_keys(input) })
        data['imprintMockupCreate']
      end

      def mockup_creates(inputs)
        data = @graphql.mutate(MOCKUP_CREATES_MUTATION, variables: { inputs: inputs.map { |i| camelize_keys(i) } })
        data['imprintMockupCreates']
      end

      private

      def fetch_page(line_item_group_id:, first: 25, after: nil, **)
        data = @graphql.query(
          ALL_QUERY,
          variables: { lineItemGroupId: line_item_group_id.to_s, first: first, after: after }
        )
        nodes = data['lineItemGroup']['imprints']['nodes'].map { |attrs| Printavo::Imprint.new(attrs) }
        page_info = data['lineItemGroup']['imprints']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
