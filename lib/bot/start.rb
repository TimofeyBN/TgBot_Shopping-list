# frozen_string_literal: true

module Bot
  module Commands
    class Start < Base
      HELP_TEXT = <<~HELP
        Я бот для списка покупок

        /add Название количество цена – добавить товар
        /list – показать список
        /buy ID – отметить купленным
        /delete ID – удалить
        /total – общая стоимость
        /help – эта справка

        Пример:
        /add Хлеб 1 45.50
        /list
        /buy 1
      HELP

      def handle
        send_message(HELP_TEXT)
      end
    end
  end
end
