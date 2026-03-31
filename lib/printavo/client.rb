# lib/printavo/client.rb
# frozen_string_literal: true

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

    def account
      Resources::Account.new(@graphql)
    end

    def contacts
      Resources::Contacts.new(@graphql)
    end

    def customers
      Resources::Customers.new(@graphql)
    end

    def expenses
      Resources::Expenses.new(@graphql)
    end

    def fees
      Resources::Fees.new(@graphql)
    end

    def imprints
      Resources::Imprints.new(@graphql)
    end

    def inquiries
      Resources::Inquiries.new(@graphql)
    end

    def invoices
      Resources::Invoices.new(@graphql)
    end

    def jobs
      Resources::Jobs.new(@graphql)
    end

    def line_item_groups
      Resources::LineItemGroups.new(@graphql)
    end

    def line_items
      Resources::LineItems.new(@graphql)
    end

    def login(*)
      raise NotImplementedError,
            'login is not supported — this gem authenticates via email + token headers. ' \
            'Pass credentials to Printavo::Client.new(email:, token:) instead.'
    end

    def logout(*)
      raise NotImplementedError,
            'logout is not supported — this gem uses stateless header-based auth. ' \
            'Simply discard the client instance when done.'
    end

    def orders
      Resources::Orders.new(@graphql)
    end

    def statuses
      Resources::Statuses.new(@graphql)
    end

    def tasks
      Resources::Tasks.new(@graphql)
    end

    def threads
      Resources::Threads.new(@graphql)
    end

    def transaction_payments
      Resources::TransactionPayments.new(@graphql)
    end

    def transactions
      Resources::Transactions.new(@graphql)
    end
  end
end
