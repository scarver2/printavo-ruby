# lib/printavo/models/base.rb
# frozen_string_literal: true

module Printavo
  module Models
    class Base
      def initialize(attributes = {})
        @attributes = (attributes || {}).transform_keys(&:to_s)
      end

      def [](key)
        @attributes[key.to_s]
      end

      def dig(*keys)
        keys.map(&:to_s).reduce(@attributes) do |obj, key|
          break nil unless obj.is_a?(Hash)

          obj[key]
        end
      end

      def to_h
        @attributes.dup
      end

      def ==(other)
        other.is_a?(self.class) && other.to_h == to_h
      end

      def inspect
        "#<#{self.class.name} #{@attributes.inspect}>"
      end
    end
  end
end
