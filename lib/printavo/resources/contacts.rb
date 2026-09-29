# lib/printavo/resources/contacts.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class Contacts < Base
      ALL_QUERY       = File.read(File.join(__dir__, '../graphql/contacts/all.graphql')).freeze
      FIND_QUERY      = File.read(File.join(__dir__, '../graphql/contacts/find.graphql')).freeze
      CREATE_MUTATION = File.read(File.join(__dir__, '../graphql/contacts/create.graphql')).freeze
      DELETE_MUTATION = File.read(File.join(__dir__, '../graphql/contacts/delete.graphql')).freeze
      UPDATE_MUTATION = File.read(File.join(__dir__, '../graphql/contacts/update.graphql')).freeze

      MAX_PAGE_SIZE = 100
      PAGE_FILTERS = %i[primary_only query sort_descending sort_on].freeze

      def all(first: 25, after: nil, **filters)
        page(first: first, after: after, **filters).records
      end

      # Fetches one bounded contact page while preserving sanitized partial
      # GraphQL errors. This method never follows the next cursor.
      #
      # @return [Printavo::Page]
      def page(first: 25, after: nil, **filters)
        validate_page!(first: first, filters: filters)
        envelope = @graphql.query_envelope(
          ALL_QUERY,
          variables: contact_variables(first: first, after: after, filters: filters)
        )
        build_page(envelope)
      end

      # Rebuilds a captured contacts page through the SDK parser without
      # performing provider network I/O.
      def page_from_response_payload(response_payload, metadata: {})
        build_page(
          @graphql.envelope_from_response_payload(response_payload, metadata: metadata)
        )
      end

      # Finds a contact by ID.
      #
      # @param id [String, Integer]
      # @return [Printavo::Contact]
      #
      # @example
      #   client.contacts.find("123")
      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Contact.new(data['contact'])
      end

      # Creates a new contact. Requires at minimum +email:+.
      #
      # @return [Printavo::Contact]
      #
      # @example
      #   client.contacts.create(first_name: "Jane", last_name: "Smith",
      #                          email: "jane@example.com", phone: "555-867-5309")
      def create(**input)
        data = @graphql.mutate(CREATE_MUTATION, variables: { input: camelize_keys(input) })
        Printavo::Contact.new(data['contactCreate'])
      end

      # Updates an existing contact by ID.
      #
      # @param id [String, Integer]
      # @return [Printavo::Contact]
      #
      # @example
      #   client.contacts.update("123", phone: "555-999-0000")
      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION,
                               variables: { id: id.to_s, input: camelize_keys(input) })
        Printavo::Contact.new(data['contactUpdate'])
      end

      # Permanently deletes a contact by ID.
      #
      # @param id [String, Integer]
      # @return [nil]
      #
      # @example
      #   client.contacts.delete("123")
      def delete(id)
        @graphql.mutate(DELETE_MUTATION, variables: { id: id.to_s })
        nil
      end

      private

      def validate_page!(first:, filters:)
        unless first.is_a?(Integer) && first.between?(1, MAX_PAGE_SIZE)
          raise ArgumentError, "first must be between 1 and #{MAX_PAGE_SIZE}"
        end

        unknown_filters = filters.keys - PAGE_FILTERS
        raise ArgumentError, "unknown contact filters: #{unknown_filters.join(', ')}" if unknown_filters.any?

        sort_on = filters[:sort_on]
        return if sort_on.nil? || Enums::ContactSortField::ALL.include?(sort_on)

        raise ArgumentError, 'sort_on must be a Printavo::Enums::ContactSortField value'
      end

      def contact_variables(first:, after:, filters:)
        {
          first: first,
          after: after,
          primaryOnly: filters[:primary_only],
          query: filters[:query],
          sortOn: filters[:sort_on],
          sortDescending: filters[:sort_descending]
        }
      end

      def build_page(envelope)
        connection = envelope.data&.fetch('contacts', nil) || {}
        records = Array(connection['nodes']).map { |attrs| Printavo::Contact.new(attrs) }
        page_info = connection.fetch('pageInfo', {})
        Printavo::Page.new(
          records: records,
          has_next_page: page_info.fetch('hasNextPage', false),
          end_cursor: page_info['endCursor'],
          errors: envelope.errors,
          metadata: envelope.metadata,
          response_payload: envelope.response_payload
        )
      end
    end
  end
end
