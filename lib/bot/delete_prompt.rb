# frozen_string_literal: true

module Bot
  module Commands
    class DeletePrompt < Base
      HINT = <<~HINT
        🗑 *Удаление товара*

        Формат: `/delete ID`

        Пример:
        `/delete 1`

        Чтобы узнать ID — нажми 📋 Список
      HINT

      def handle
        send_message(HINT, parse_mode: 'Markdown')
      end
    end
  end
end
