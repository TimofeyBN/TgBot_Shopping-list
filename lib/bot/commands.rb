# frozen_string_literal: true

require 'shopping_list_manager'
require 'stringio'

module Bot
  class Commands
    def self.handle(bot, message)
      return if message.text.nil? || message.text.empty?

      text = message.text.to_s

      case text
      when '/start', '/help'
        help_text = <<~HELP
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
        send(bot, message, help_text)

      when %r{^/add}
        handle_add(bot, message)

      when '/list'
        run_cli(bot, message, ['list'])

      when %r{^/buy}
        id = message.text.split[1]
        if id.nil? || id !~ /^\d+$/
          send(bot, message, 'Укажите ID товара: /buy 2')
        else
          run_cli(bot, message, ['buy', id])
        end

      when %r{^/delete}
        id = message.text.split[1]
        if id.nil? || id !~ /^\d+$/
          send(bot, message, 'Укажите ID товара: /delete 3')
        else
          run_cli(bot, message, ['delete', id])
        end

      when '/total'
        run_cli(bot, message, ['total'])


      else
        send(bot, message, 'Неизвестная команда')
      end
    end

    def self.main_keyboard
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard: [
          ['📋 Список', '➕ Добавить'],
          ['💰 Итог', '❌ Удалить'],
          ['✅ Купить']
        ],
        resize_keyboard: true
      )
    end

    # --- ADD ---
    def self.handle_add(bot, message)
      # Удаляем команду /add и лишние пробелы
      text = message.text.sub(%r{^/add\s*}, '')

      # Ищем два последних аргумента как числа (количество и цена)
      parts = text.split

      if parts.size < 3
        send(bot, message, "Формат: /add Название количество цена\nПример: /add Хлеб 1 45.90")
        return
      end

      # Последние два элемента – количество и цена
      price_str = parts.pop
      quantity_str = parts.pop

      # Оставшиеся части – название (может быть из нескольких слов)
      name = parts.join(' ')

      # Валидация чисел
      unless quantity_str =~ /\A\d+\z/ && price_str =~ /\A\d+(\.\d+)?\z/
        send(bot, message, 'Ошибка: количество должно быть целым числом, цена — числом (например, 2 и 45.99)')
        return
      end

      args = ['add', name, '--quantity', quantity_str, '--price', price_str]
      run_cli(bot, message, args)
    end

    # --- CLI RUNNER ---
    def self.run_cli(bot, message, args)
      user_id = message.from&.id || message.chat.id
      file = "data_#{user_id}.json"

      full_args = args.dup + ['--file', file]

      output = capture_stdout do
        ShoppingListManager::CLI.run(full_args)
      end

      send(bot, message, output.empty? ? 'Готово ✅' : output)
    rescue StandardError => e
      send(bot, message, "Ошибка: #{e.message}")
    end

    # --- UTILS ---
    def self.send(bot, message, text)
      bot.api.send_message(chat_id: message.chat.id, text: text)
    end

    def self.capture_stdout
      old_stdout = $stdout
      $stdout = StringIO.new
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end
end
