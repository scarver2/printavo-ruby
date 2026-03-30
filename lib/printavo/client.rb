# lib/printavo/client.rb
module Printavo
  class Client
    attr_reader :graphql

    # Creates a new Printavo API client. Each instance is independent —
    # multiple clients with different credentials can coexist in one process.
    #
    # @param email   [String] the email address associated with your Printavo account
    # @param token   [String] the API token from your Printavo My Account page
    # @param timeout [Integer] HTTP timeout in seconds (default: 30)
    #
    # @example
    #   client = Printavo::Client.new(
    #     email: ENV["PRINTAVO_EMAIL"],
    #     token: ENV["PRINTAVO_TOKEN"]
    #   )
    #   client.customers.all
    #   client.orders.find("12345")
    #   client.graphql.query("{ customers { nodes { id } } }")
    def initialize(email:, token:, timeout: 30)
      connection = Connection.new(email: email, token: token, timeout: timeout).build
      @graphql   = GraphqlClient.new(connection)
    end

    def customers
      Resources::Customers.new(@graphql)
    end

    def statuses
      Resources::Statuses.new(@graphql)
    end

    def orders
      Resources::Orders.new(@graphql)
    end

    def jobs
      Resources::Jobs.new(@graphql)
    end

    def inquiries
      Resources::Inquiries.new(@graphql)
    end
  end
end
