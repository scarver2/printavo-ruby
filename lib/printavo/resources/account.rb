# lib/printavo/resources/account.rb
# frozen_string_literal: true

module Printavo
  module Resources
    # Singleton resource — Printavo exposes one account per API credential.
    # Use +client.account.find+ (no ID argument required).
    class Account < Base
      FIND_QUERY = File.read(File.join(__dir__, '../graphql/account/find.graphql')).freeze

      # Returns the account associated with the current API credentials.
      #
      # @return [Printavo::Account]
      #
      # @example
      #   account = client.account.find
      #   puts account.company_name   # => "Texas Embroidery Ranch"
      #   puts account.locale         # => "en-US"
      def find
        data = @graphql.query(FIND_QUERY)
        Printavo::Account.new(data['account'])
      end
    end
  end
end
