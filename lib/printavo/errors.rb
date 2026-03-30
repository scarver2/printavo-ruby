# lib/printavo/errors.rb
# frozen_string_literal: true

module Printavo
  class Error < StandardError; end

  class AuthenticationError < Error; end

  class RateLimitError < Error; end

  class NotFoundError < Error; end

  class ApiError < Error
    attr_reader :response

    def initialize(message, response: nil)
      super(message)
      @response = response
    end
  end
end
