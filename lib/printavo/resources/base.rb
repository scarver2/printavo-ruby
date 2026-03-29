# lib/printavo/resources/base.rb
module Printavo
  module Resources
    class Base
      def initialize(graphql)
        @graphql = graphql
      end
    end
  end
end
