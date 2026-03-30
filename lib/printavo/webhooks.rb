# lib/printavo/webhooks.rb
# frozen_string_literal: true

require 'openssl'

module Printavo
  module Webhooks
    # Verifies a Printavo webhook signature using HMAC-SHA256.
    #
    # Uses a constant-time comparison to prevent timing attacks.
    #
    # @param signature [String] the signature from the X-Printavo-Signature header
    # @param payload   [String] the raw request body string
    # @param secret    [String] your webhook secret configured in Printavo
    # @return [Boolean]
    #
    # @example Rails controller
    #   if Printavo::Webhooks.verify(
    #        request.headers["X-Printavo-Signature"],
    #        request.raw_post,
    #        ENV["PRINTAVO_WEBHOOK_SECRET"]
    #      )
    #     # process event
    #   else
    #     head :unauthorized
    #   end
    def self.verify(signature, payload, secret)
      return false if signature.nil? || payload.nil? || secret.nil?

      expected = OpenSSL::HMAC.hexdigest('SHA256', secret, payload)
      OpenSSL.secure_compare(expected, signature)
    rescue ArgumentError, TypeError
      false
    end
  end
end
