# frozen_string_literal: true

require 'stringio'
require 'shopping_list_manager'

module Bot
  module Commands
    # Обрабатывает нажатия на inline-кнопки ✅ Купить и 🗑 Удалить
    class CallbackHandler
      def initialize(bot, query)
        @bot   = bot
        @query = query
        # Для совместимости с методами Base используем message из query
        @message = query.message
      end

      def handle
        action, item_id = @query.data.split(':', 2)

        case action
        when 'buy'    then perform('buy',    item_id, '✅ Отмечено как купленное!')
        when 'delete' then perform('delete', item_id, '🗑 Товар удалён')
        else
          answer_query('Неизвестное действие')
        end
      end

      private

      def perform(cli_action, item_id, success_text)
        output = run_cli([cli_action, item_id])

        text = output.strip.empty? ? success_text : output
        answer_query(text)

        # Убираем кнопки с сообщения после действия
        @bot.api.edit_message_reply_markup(
          chat_id:      @message.chat.id,
          message_id:   @message.message_id,
          reply_markup: Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: [])
        )

        # Обновляем текст сообщения — добавляем статус
        status = cli_action == 'buy' ? ' ✅' : ' 🗑'
        @bot.api.edit_message_text(
          chat_id:    @message.chat.id,
          message_id: @message.message_id,
          text:       @message.text.to_s + status
        )
      rescue Telegram::Bot::Exceptions::ResponseError
        # Игнорируем ошибку если сообщение не изменилось
      end

      def answer_query(text)
        @bot.api.answer_callback_query(
          callback_query_id: @query.id,
          text:              text,
          show_alert:        false
        )
      end

      def run_cli(args)
        user_id   = @query.from&.id
        Dir.mkdir('data') unless Dir.exist?('data')
        file      = "data/data_#{user_id}.json"
        full_args = args + ['--file', file]

        old_stdout = $stdout
        $stdout    = StringIO.new
        ShoppingListManager::CLI.run(full_args)
        $stdout.string
      rescue StandardError => e
        "❌ Ошибка: #{e.message}"
      ensure
        $stdout = old_stdout
      end
    end
  end
end
