# lib/printavo/resources/contacts.rb
# frozen_string_literal: true

module Printavo
  module Resources
    class Contacts < Base
      FIND_QUERY      = File.read(File.join(__dir__, '../graphql/contacts/find.graphql')).freeze
      CREATE_MUTATION = File.read(File.join(__dir__, '../graphql/contacts/create.graphql')).freeze
      UPDATE_MUTATION = File.read(File.join(__dir__, '../graphql/contacts/update.graphql')).freeze

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
    end
  end
end
