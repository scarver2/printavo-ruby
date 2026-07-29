# lib/printavo/graphql_client.rb
# frozen_string_literal: true

require 'digest'
require 'json'

module Printavo
  class GraphqlClient
    SAFE_ERROR_EXTENSION_KEYS = %w[classification code].freeze
    SAFE_METADATA_HEADERS = %w[
      retry-after
      x-request-id
      x-ratelimit-limit
      x-ratelimit-remaining
      x-ratelimit-reset
    ].freeze

    # @param connection  [Faraday::Connection]
    # @param cache       [#fetch, #delete, nil] any cache store implementing
    #                    +fetch(key, expires_in:) { }+ and +delete(key)+,
    #                    e.g. +Rails.cache+, +Printavo::MemoryStore.new+, or +nil+
    # @param default_ttl [Integer] default TTL in seconds applied to cached queries (default: 300)
    # @param sensitive_values [Array<String>] credentials to redact from provider messages
    def initialize(connection, cache: nil, default_ttl: 300, sensitive_values: [])
      @connection  = connection
      @cache       = cache
      @default_ttl = default_ttl
      @sensitive_values = sensitive_values.filter_map do |value|
        string = value.to_s
        string unless string.empty?
      end.freeze
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

    # Executes a GraphQL query without discarding partial data when GraphQL
    # errors are present. HTTP and transport failures still raise their
    # identifier-only SDK exceptions.
    #
    # @return [Printavo::ResponseEnvelope]
    def query_envelope(query_string, variables: {})
      execute_envelope(query_string, variables: variables)
    end

    # Mutation equivalent of #query_envelope. Callers must decide whether a
    # partial mutation response represents an uncertain write.
    #
    # @return [Printavo::ResponseEnvelope]
    def mutate_envelope(mutation_string, variables: {})
      execute_envelope(mutation_string, variables: variables)
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
      envelope = execute_envelope(document, variables: variables)
      return envelope.data if envelope.success?

      messages = envelope.errors.map { |error| error.fetch('message') }.join(', ')
      raise ApiError.new(messages, response: { 'errors' => envelope.errors }.freeze)
    end

    def execute_envelope(document, variables: {})
      response = @connection.post('') do |req|
        req.body = JSON.generate(query: document, variables: variables)
      end
      handle_envelope(response)
    rescue Faraday::Error
      raise TransportError, 'Printavo transport request failed', cause: nil
    end

    def handle_envelope(response)
      case response.status
      when 401 then raise AuthenticationError, 'Invalid credentials — check your email and token'
      when 429 then raise RateLimitError, 'Printavo rate limit exceeded (10 req/5 sec)'
      when 404 then raise NotFoundError, 'Resource not found'
      end

      body = response.body
      return malformed_envelope(response) unless valid_envelope?(body)

      ResponseEnvelope.new(
        data: body['data'],
        errors: sanitize_errors(body.fetch('errors', [])),
        metadata: safe_metadata(response)
      )
    end

    def valid_envelope?(body)
      return false unless body.is_a?(Hash)
      return false unless body.key?('data') || body.key?('errors')
      return false unless body['data'].nil? || body['data'].is_a?(Hash)

      errors = body.fetch('errors', [])
      errors.is_a?(Array) && errors.all?(Hash)
    end

    def malformed_envelope(response)
      ResponseEnvelope.new(
        data: nil,
        errors: [
          {
            'message' => 'Malformed GraphQL response',
            'extensions' => { 'code' => 'MALFORMED_RESPONSE' }
          }
        ],
        metadata: safe_metadata(response)
      )
    end

    def sanitize_errors(errors)
      errors.map do |error|
        {
          'message' => redact(error.fetch('message', 'GraphQL request failed').to_s)[0, 500],
          'path' => sanitize_path(error['path']),
          'locations' => sanitize_locations(error['locations']),
          'extensions' => sanitize_extensions(error['extensions'])
        }.compact
      end
    end

    def sanitize_path(path)
      return unless path.is_a?(Array)

      path.select { |part| part.is_a?(String) || part.is_a?(Integer) }
    end

    def sanitize_locations(locations)
      return unless locations.is_a?(Array)

      locations.filter_map do |location|
        next unless location.is_a?(Hash)

        line = location['line']
        column = location['column']
        { 'line' => line, 'column' => column } if line.is_a?(Integer) && column.is_a?(Integer)
      end
    end

    def sanitize_extensions(extensions)
      return unless extensions.is_a?(Hash)

      extensions.slice(*SAFE_ERROR_EXTENSION_KEYS).transform_values { |value| redact(value.to_s)[0, 100] }
    end

    def safe_metadata(response)
      headers = response.headers.to_h.transform_keys(&:downcase)
      SAFE_METADATA_HEADERS.each_with_object({}) do |header, metadata|
        value = headers[header]
        metadata[header] = redact(value.to_s)[0, 100] unless value.nil?
      end
    end

    def redact(value)
      @sensitive_values.reduce(value.dup) { |result, secret| result.gsub(secret, '[FILTERED]') }
    end

    # Resolves a dot-separated path against a nested hash.
    # e.g. dig_path(data, "customer.orders") => data["customer"]["orders"]
    def dig_path(data, path)
      path.split('.').reduce(data) { |obj, key| obj.is_a?(Hash) ? obj[key] : nil }
    end
  end
end
