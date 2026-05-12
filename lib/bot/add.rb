# frozen_string_literal: true

module Bot
  module Commands
    class Add < Base
      FORMAT_HINT = <<~HINT
        ➕ *Добавление товара*

        Формат: `/add Название количество цена`

        Примеры:
        `/add Хлеб 1 45.90`
        `/add Молоко цельное 2 89`
      HINT

      def handle
        # Убираем и slash-команду и текст кнопки (без слеша)
        text = @message.text
                       .sub(/\A\/add\s*/i, '')
                       .sub(/\A➕\s*Добавить товар\s*/i, '')
                       .strip
        parts = text.split

        if parts.size < 3
          send_message(FORMAT_HINT, parse_mode: 'Markdown')
          return
        end

        price_str    = parts.pop
        quantity_str = parts.pop
        name         = parts.join(' ')

        unless quantity_str =~ /\A\d+\z/ && price_str =~ /\A\d+(\.\d+)?\z/
          send_message('❌ Количество — целое число, цена — число (например: 2 и 45.99)')
          return
        end

        run_cli(['add', name, '--quantity', quantity_str, '--price', price_str])
      end
    end
  end
end
