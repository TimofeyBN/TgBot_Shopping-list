# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv/load'
require_relative 'lib/bot/commands'

token = ENV['TELEGRAM_BOT_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    puts ">>> #{message.text}"
    Bot::Commands.handle(bot, message)
  end
end
