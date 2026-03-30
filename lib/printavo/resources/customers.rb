# lib/printavo/resources/customers.rb
module Printavo
  module Resources
    class Customers < Base
      ALL_QUERY = <<~GQL.freeze
        query Customers($first: Int, $after: String) {
          customers(first: $first, after: $after) {
            nodes {
              id
              firstName
              lastName
              email
              phone
              company
            }
            pageInfo {
              hasNextPage
              endCursor
            }
          }
        }
      GQL

      FIND_QUERY = <<~GQL.freeze
        query Customer($id: ID!) {
          customer(id: $id) {
            id
            firstName
            lastName
            email
            phone
            company
          }
        }
      GQL

      CREATE_MUTATION = <<~GQL.freeze
        mutation CustomerCreate($input: CustomerCreateInput!) {
          customerCreate(input: $input) {
            id
            companyName
            primaryContact {
              id
              firstName
              lastName
              email
              phone
            }
          }
        }
      GQL

      UPDATE_MUTATION = <<~GQL.freeze
        mutation CustomerUpdate($id: ID!, $input: CustomerInput!) {
          customerUpdate(id: $id, input: $input) {
            id
            companyName
            primaryContact {
              id
              firstName
              lastName
              email
              phone
            }
          }
        }
      GQL

      def all(first: 25, after: nil)
        fetch_page(first: first, after: after).records
      end

      def find(id)
        data = @graphql.query(FIND_QUERY, variables: { id: id.to_s })
        Printavo::Customer.new(data['customer'])
      end

      # Creates a new customer. Requires a +primary_contact+ hash with at least
      # +firstName+ and +email+. Optional keyword arguments map to CustomerCreateInput.
      #
      # @param primary_contact [Hash] contact fields (firstName, lastName, email, phone)
      # @return [Printavo::Customer]
      #
      # @example
      #   client.customers.create(
      #     primary_contact: { firstName: "Jane", lastName: "Smith", email: "jane@example.com" },
      #     company_name: "Acme Shirts"
      #   )
      def create(primary_contact:, **input)
        variables = { input: camelize_keys(input).merge(primaryContact: primary_contact) }
        data = @graphql.mutate(CREATE_MUTATION, variables: variables)
        build_customer(data['customerCreate'])
      end

      # Updates an existing customer by ID.
      #
      # @param id  [String, Integer]
      # @return [Printavo::Customer]
      #
      # @example
      #   client.customers.update("42", company_name: "New Name")
      def update(id, **input)
        data = @graphql.mutate(UPDATE_MUTATION,
                               variables: { id: id.to_s, input: camelize_keys(input) })
        build_customer(data['customerUpdate'])
      end

      private

      def fetch_page(first: 25, after: nil, **)
        data = @graphql.query(ALL_QUERY, variables: { first: first, after: after })
        nodes = data['customers']['nodes'].map { |attrs| Printavo::Customer.new(attrs) }
        page_info = data['customers']['pageInfo']
        Printavo::Page.new(
          records: nodes,
          has_next_page: page_info['hasNextPage'],
          end_cursor: page_info['endCursor']
        )
      end

      # Normalizes a mutation response into the shape Customer.new expects.
      # The mutation returns companyName + nested primaryContact; our model
      # reads company, firstName, lastName, email, phone from the top level.
      def build_customer(attrs)
        return nil unless attrs

        normalized = attrs.dup
        normalized['company'] ||= attrs['companyName']
        if (contact = attrs['primaryContact'])
          %w[firstName lastName email phone].each do |field|
            normalized[field] ||= contact[field]
          end
        end
        Printavo::Customer.new(normalized)
      end

      # Converts snake_case Ruby keyword args to camelCase for GraphQL input.
      def camelize_keys(hash)
        hash.transform_keys do |key|
          key.to_s.gsub(/_([a-z])/) { ::Regexp.last_match(1).upcase }
        end
      end
    end
  end
end
