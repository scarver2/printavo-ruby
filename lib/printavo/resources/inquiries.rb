# lib/printavo/resources/inquiries.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class Inquiries < Base
      ALL_QUERY       = File.read(File.join(__dir__, '../graphql/inquiries/all.graphql')).freeze
      FIND_QUERY      = File.read(File.join(__dir__, '../graphql/inquiries/find.graphql')).freeze
      CREATE_MUTATION = File.read(File.join(__dir__, '../graphql/inquiries/create.graphql')).freeze
      DELETE_MUTATION = File.read(File.join(__dir__, '../graphql/inquiries/delete.graphql')).freeze
      UPDATE_MUTATION = File.read(File.join(__dir__, '../graphql/inquiries/update.graphql')).freeze

      def all(first: 25, after: nil)
        fetch_page(first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Inquiry.new(data['inquiry'])
      end

      # Creates a new inquiry. Requires +name:+ at minimum.
      #
      # @return [Printavo::Inquiry]
      #
      # @example
      #   client.inquiries.create(name: "Jane Smith", email: "jane@example.com",
      #                           request: "100 hoodies, front + back print")
      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: input })
        Printavo::Inquiry.new(data['inquiryCreate'])
      end

      # Updates an existing inquiry by ID.
      #
      # @param id [String, Integer]
      # @return [Printavo::Inquiry]
      #
      # @example
      #   client.inquiries.update("55", nickname: "Hoodies Rush")
      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION,
                               variables: { id: id.to_s, input: input })
        Printavo::Inquiry.new(data['inquiryUpdate'])
      end

      # Permanently deletes an inquiry by ID.
      #
      # @param id [String, Integer]
      # @return [nil]
      #
      # @example
      #   client.inquiries.delete("55")
      def delete(id)
        @graphql.mutate(DELETE_MUTATION, variables: { id: id.to_s })
        nil
      end

      private

      def fetch_page(first: 25, after: nil, **)
        data = @graphql.query(ALL_QUERY, variables: { first: first, after: after })
        nodes = data['inquiries']['nodes'].map { |attrs| Printavo::Inquiry.new(attrs) }
        page_info = data['inquiries']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end
    end
  end
end
