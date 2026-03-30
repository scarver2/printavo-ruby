# lib/printavo.rb
require 'faraday'
require 'faraday/retry'
require 'json'

require_relative 'printavo/version'
require_relative 'printavo/errors'
require_relative 'printavo/config'
require_relative 'printavo/connection'
require_relative 'printavo/graphql_client'
require_relative 'printavo/models/base'
require_relative 'printavo/models/customer'
require_relative 'printavo/models/status'
require_relative 'printavo/models/order'
require_relative 'printavo/models/job'
require_relative 'printavo/models/inquiry'
require_relative 'printavo/resources/base'
require_relative 'printavo/resources/customers'
require_relative 'printavo/resources/statuses'
require_relative 'printavo/resources/orders'
require_relative 'printavo/resources/jobs'
require_relative 'printavo/resources/inquiries'
require_relative 'printavo/webhooks'
require_relative 'printavo/client'

module Printavo
end
