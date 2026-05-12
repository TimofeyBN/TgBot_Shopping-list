# frozen_string_literal: true

module Bot
  module Commands
    class List < Base
      def handle
        raw = run_cli_raw(['list'])

        if raw.nil? || raw.strip.empty?
          send_message('🛒 Список пуст. Добавьте товары кнопкой ➕ или командой /add')
          return
        end

        lines = raw.strip.split("\n")

        # Ищем строки с товарами — они начинаются с числа (ID)
        # Предполагаемый формат: "1. Хлеб x1 — 45.50₽" или "1) Хлеб ..."
        item_lines, other_lines = lines.partition { |l| l.match?(/^\d+[.)]\s/) }

        # Отправляем заголовок / итоговые строки (если есть) как одно сообщение
        send_message(other_lines.join("\n"), reply_markup: main_keyboard) unless other_lines.empty?

        # Каждый товар — отдельное сообщение с inline-кнопками
        item_lines.each do |line|
          item_id = line[/^(\d+)/, 1]
          next unless item_id

          @bot.api.send_message(
            chat_id:      @message.chat.id,
            text:         line,
            reply_markup: item_inline_keyboard(item_id)
          )
        end

        # Формат не совпал с ожидаемым — other_lines уже содержит весь вывод,
        # двойная отправка не нужна
      end
    end
  end
end
