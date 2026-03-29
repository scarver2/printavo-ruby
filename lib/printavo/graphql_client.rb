# lib/printavo/graphql_client.rb
require 'json'

module Printavo
  class GraphqlClient
    def initialize(connection)
      @connection = connection
    end

    def query(query_string, variables: {})
      response = @connection.post('') do |req|
        req.body = JSON.generate(query: query_string, variables: variables)
      end

      handle_response(response)
    end

    private

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
  end
end
