# lib/printavo/connection.rb
# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'

module Printavo
  class Connection
    # @param email               [String]  Printavo account email
    # @param token               [String]  Printavo API token
    # @param base_url            [String]  API base URL (default: Config::BASE_URL)
    # @param timeout             [Integer] HTTP timeout in seconds (default: 30)
    # @param max_retries         [Integer] Max retry attempts on 5xx/429 (default: 2)
    # @param retry_on_rate_limit [Boolean] Retry on 429 Too Many Requests (default: true)
    def initialize(email:, token:, base_url: Config::BASE_URL, timeout: 30, # rubocop:disable Metrics/ParameterLists
                   max_retries: 2, retry_on_rate_limit: true)
      @email               = email
      @token               = token
      @base_url            = base_url
      @timeout             = timeout
      @max_retries         = max_retries
      @retry_on_rate_limit = retry_on_rate_limit
    end

    def build
      Faraday.new(url: @base_url) do |f|
        f.headers['Content-Type'] = 'application/json'
        f.headers['Accept']       = 'application/json'
        f.headers['email']        = @email
        f.headers['token']        = @token
        f.request :retry, **retry_options
        f.response :json
        f.options.timeout      = @timeout
        f.options.open_timeout = @timeout
        f.adapter Faraday.default_adapter
      end
    end

    private

    # Exponential backoff: base interval × 2^attempt, ±50% jitter.
    # interval_randomness adds up to 50% random variance per retry.
    def retry_options
      {
        max: @max_retries,
        interval: 0.5,
        backoff_factor: 2,
        interval_randomness: 0.5,
        retry_statuses: retry_statuses
      }
    end

    # Returns the set of HTTP status codes that trigger a retry.
    # 429 is only included when +retry_on_rate_limit+ is true (the default).
    def retry_statuses
      statuses = [500, 502, 503]
      statuses << 429 if @retry_on_rate_limit
      statuses
    end
  end
end
