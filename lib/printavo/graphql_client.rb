# lib/printavo/graphql_client.rb
# frozen_string_literal: true

require 'digest'
require 'json'

module Printavo
  class GraphqlClient
    # @param connection  [Faraday::Connection]
    # @param cache       [#fetch, #delete, nil] any cache store implementing
    #                    +fetch(key, expires_in:) { }+ and +delete(key)+,
    #                    e.g. +Rails.cache+, +Printavo::MemoryStore.new+, or +nil+
    # @param default_ttl [Integer] default TTL in seconds applied to cached queries (default: 300)
    def initialize(connection, cache: nil, default_ttl: 300)
      @connection  = connection
      @cache       = cache
      @default_ttl = default_ttl
    end

    # Executes a GraphQL query and returns the parsed `data` hash.
    #
    # @param query_string [String] the GraphQL query document
    # @param variables    [Hash]   optional input variables
    # @return [Hash]
    #
    # @example
    #   client.graphql.query("{ customers { nodes { id } } }")
    #   client.graphql.query(
    #     "query Customer($id: ID!) { customer(id: $id) { id email } }",
    #     variables: { id: "42" }
    #   )
    def query(query_string, variables: {})
      return execute(query_string, variables: variables) unless @cache

      @cache.fetch(cache_key(query_string, variables), expires_in: @default_ttl) do
        execute(query_string, variables: variables)
      end
    end

    # Executes a GraphQL mutation and returns the parsed `data` hash.
    # Semantically equivalent to `query` — both POST to the same endpoint —
    # but distinguishes write intent at the call site.
    #
    # @param mutation_string [String] the GraphQL mutation document
    # @param variables       [Hash]   optional input variables
    # @return [Hash]
    #
    # @example
    #   client.graphql.mutate(
    #     <<~GQL,
    #       mutation UpdateOrder($id: ID!, $input: OrderInput!) {
    #         updateOrder(id: $id, input: $input) {
    #           order { id nickname }
    #           errors
    #         }
    #       }
    #     GQL
    #     variables: { id: "99", input: { nickname: "Rush Job" } }
    #   )
    def mutate(mutation_string, variables: {})
      execute(mutation_string, variables: variables)
    end

    # Iterates all pages of a paginated GraphQL query, yielding each page's
    # nodes array. The query must accept `$first: Int` and `$after: String`
    # variables, and the target connection must expose `nodes` and `pageInfo`.
    #
    # @param query_string [String] the GraphQL query document
    # @param path         [String] dot-separated key path to the connection in the response
    #                              e.g. "orders" or "customer.orders"
    # @param variables    [Hash]   additional variables merged with `first` and `after`
    # @param first        [Integer] page size (default 25)
    # @yieldparam nodes   [Array<Hash>] one page of raw node hashes
    #
    # @example
    #   client.graphql.paginate(ORDERS_QUERY, path: "orders") do |nodes|
    #     nodes.each { |n| puts n["nickname"] }
    #   end
    #
    # @example With extra variables
    #   client.graphql.paginate(JOBS_QUERY, path: "order.lineItems",
    #                           variables: { orderId: "99" }, first: 50) do |nodes|
    #     nodes.each { |j| puts j["name"] }
    #   end
    def paginate(query_string, path:, variables: {}, first: 25)
      after = nil
      loop do
        data  = execute(query_string, variables: variables.merge(first: first, after: after))
        conn  = dig_path(data, path)
        nodes = conn&.fetch('nodes', []) || []
        yield nodes
        page_info = conn&.fetch('pageInfo', {}) || {}
        break unless page_info['hasNextPage']

        after = page_info['endCursor']
      end
    end

    private

    # Generates a stable, namespaced cache key from the query document and variables.
    # Whitespace in the query is collapsed so formatting differences don't cause misses.
    def cache_key(query_string, variables)
      payload = JSON.generate([query_string.gsub(/\s+/, ' ').strip, variables])
      "printavo:gql:#{Digest::SHA256.hexdigest(payload)[0, 16]}"
    end

    def execute(document, variables: {})
      response = @connection.post('') do |req|
        req.body = JSON.generate(query: document, variables: variables)
      end
      handle_response(response)
    end

    def handle_response(response)
      body = response.body

      case response.status
      when 401 then raise AuthenticationError, 'Invalid credentials — check your email and token'
      when 429 then raise RateLimitError, 'Printavo rate limit exceeded (10 req/5 sec)'
      when 404 then raise NotFoundError, 'Resource not found'
      end

      errors = body.is_a?(Hash) ? body['errors'] : nil
      if errors&.any?
        messages = errors.map { |e| e['message'] }.join(', ')
        raise ApiError.new(messages, response: body)
      end

      body.is_a?(Hash) ? body['data'] : body
    end

    # Resolves a dot-separated path against a nested hash.
    # e.g. dig_path(data, "customer.orders") => data["customer"]["orders"]
    def dig_path(data, path)
      path.split('.').reduce(data) { |obj, key| obj.is_a?(Hash) ? obj[key] : nil }
    end
  end
end
