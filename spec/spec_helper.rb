# spec/spec_helper.rb
require 'rspec'
require 'stringio'
require 'telegram/bot'

# Добавляем пути в LOAD_PATH
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../..', __FILE__)

# Имитируем CLI, если он не загружен
unless defined?(ShoppingListManager)
  module ShoppingListManager
    class CLI
      def self.run(args); end
    end
  end
end

require 'bot/commands'

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
end