# frozen_string_literal: true

require 'rspec'
require 'telegram/bot'
require_relative '../lib/bot/commands'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec
end
