# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv/load'
require_relative 'lib/bot/commands'

token = ENV['TELEGRAM_BOT_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |update|
    case update
    when Telegram::Bot::Types::Message
      puts ">>> message: #{update.text}"
      Bot::Commands.handle(bot, update)
    when Telegram::Bot::Types::CallbackQuery
      puts ">>> callback: #{update.data}"
      Bot::Commands.handle_callback(bot, update)
    end
  end
end
