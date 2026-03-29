# lib/printavo/connection.rb
require 'faraday'
require 'faraday/retry'

module Printavo
  class Connection
    def initialize(email:, token:, base_url: Config::BASE_URL, timeout: 30)
      @email    = email
      @token    = token
      @base_url = base_url
      @timeout  = timeout
    end

    def build
      Faraday.new(url: @base_url) do |f|
        f.headers['Content-Type'] = 'application/json'
        f.headers['Accept']       = 'application/json'
        f.headers['email']        = @email
        f.headers['token']        = @token

        f.request :retry, max: 2, interval: 0.5, retry_statuses: [429, 500, 502, 503]

        f.response :json
        f.options.timeout      = @timeout
        f.options.open_timeout = @timeout

        f.adapter Faraday.default_adapter
      end
    end
  end
end
