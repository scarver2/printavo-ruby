# lib/printavo/config.rb
# frozen_string_literal: true

module Printavo
  class Config
    attr_accessor :email, :token, :base_url, :timeout

    BASE_URL = 'https://www.printavo.com/api/v2'

    def initialize
      @base_url = BASE_URL
      @timeout  = 30
    end
  end
end
