# frozen_string_literal: true

module Bot
  module Commands
    class Add < Base
      def handle
        text  = @message.text.sub(%r{^/add\s*}, '')
        parts = text.split

        if parts.size < 3
          send_message("Формат: /add Название количество цена\nПример: /add Хлеб 1 45.90")
          return
        end

        price_str    = parts.pop
        quantity_str = parts.pop
        name         = parts.join(' ')

        unless quantity_str =~ /\A\d+\z/ && price_str =~ /\A\d+(\.\d+)?\z/
          send_message('Ошибка: количество должно быть целым числом, цена — числом (например, 2 и 45.99)')
          return
        end

        run_cli(['add', name, '--quantity', quantity_str, '--price', price_str])
      end
    end
  end
end