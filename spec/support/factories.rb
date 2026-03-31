# spec/support/factories.rb
# frozen_string_literal: true

Dir[File.join(__dir__, 'factories/*.rb')].each { |f| require f }
