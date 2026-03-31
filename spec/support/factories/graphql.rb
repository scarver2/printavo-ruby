# spec/support/factories/graphql.rb
# frozen_string_literal: true

module Factories
  def stub_graphql_response(data)
    { 'data' => data }.to_json
  end
end
