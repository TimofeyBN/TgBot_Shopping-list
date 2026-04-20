require 'telegram/bot'
require 'dotenv/load'
require_relative 'lib/bot/commands'

token = ENV['TELEGRAM_BOT_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    Bot::Commands.handle(bot, message)
  end
end
