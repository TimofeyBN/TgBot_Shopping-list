# frozen_string_literal: true

module Bot
  module Commands
    class Start < Base
      HELP_TEXT = <<~HELP
        👋 Привет! Я бот для списка покупок.

        Используй кнопки внизу или команды:

        /add Название количество цена – добавить товар
        /list – показать список
        /buy ID – отметить купленным
        /delete ID – удалить
        /total – общая стоимость

        📌 Пример:
        /add Хлеб 1 45.50
      HELP

      def handle
        send_message(HELP_TEXT, reply_markup: main_keyboard)
      end
    end
  end
end
