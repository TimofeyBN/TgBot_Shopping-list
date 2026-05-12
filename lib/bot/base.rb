# frozen_string_literal: true

require 'stringio'
require 'shopping_list_manager'

module Bot
  module Commands
    class Base
      def initialize(bot, message)
        @bot     = bot
        @message = message
      end

      def handle
        raise NotImplementedError, "#{self.class}#handle не реализован"
      end

      private

      # Отправить текст с опциональной клавиатурой
      def send_message(text, reply_markup: main_keyboard, parse_mode: nil)
        params = {
          chat_id:      @message.chat.id,
          text:         text,
          reply_markup: reply_markup
        }
        params[:parse_mode] = parse_mode if parse_mode
        @bot.api.send_message(params)
      end

      # Постоянная reply-клавиатура внизу экрана
      def main_keyboard
        Telegram::Bot::Types::ReplyKeyboardMarkup.new(
          keyboard: [
            [{ text: '📋 Список' },        { text: '💰 Итого' }],
            [{ text: '➕ Добавить товар' }, { text: '🗑 Удалить товар' }],
            [{ text: '❓ Помощь' }]
          ],
          resize_keyboard:  true,
          persistent:       true
        )
      end

      # Inline-клавиатура для одного товара
      def item_inline_keyboard(item_id)
        Telegram::Bot::Types::InlineKeyboardMarkup.new(
          inline_keyboard: [[
            Telegram::Bot::Types::InlineKeyboardButton.new(
              text:          '✅ Купить',
              callback_data: "buy:#{item_id}"
            ),
            Telegram::Bot::Types::InlineKeyboardButton.new(
              text:          '🗑 Удалить',
              callback_data: "delete:#{item_id}"
            )
          ]]
        )
      end

      def run_cli(args)
        user_id   = @message.from&.id || @message.chat.id
        Dir.mkdir('data') unless Dir.exist?('data')
        file      = "data/data_#{user_id}.json"
        full_args = args + ['--file', file]

        output = capture_stdout { ShoppingListManager::CLI.run(full_args) }
        send_message(output.empty? ? '✅ Готово' : output)
      rescue StandardError => e
        send_message("❌ Ошибка: #{e.message}")
      end

      # Запустить CLI и вернуть сырой текст (без отправки)
      def run_cli_raw(args)
        user_id   = @message.from&.id || @message.chat.id
        Dir.mkdir('data') unless Dir.exist?('data')
        file      = "data/data_#{user_id}.json"
        full_args = args + ['--file', file]

        capture_stdout { ShoppingListManager::CLI.run(full_args) }
      rescue StandardError => e
        "❌ Ошибка: #{e.message}"
      end

      def capture_stdout
        old_stdout = $stdout
        $stdout    = StringIO.new
        yield
        $stdout.string
      ensure
        $stdout = old_stdout
      end
    end
  end
end
