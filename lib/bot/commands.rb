# frozen_string_literal: true

require 'shopping_list_manager'
require 'stringio'

module Bot
  class Commands
    FILE_PATTERN   = 'data_%<id>s.json'
    UNKNOWN_CMD    = "Неизвестная команда. Напиши /help"
    ID_FORMAT_ERR  = "Укажите ID товара: /%<cmd>s 3"

    HELP_TEXT = <<~HELP
      Я бот для списка покупок 🛒

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

    def self.handle(bot, message)
      return if message.text.nil? || message.text.empty?

      text = message.text.to_s

      case text
      when '/start', '/help'
        reply(bot, message, HELP_TEXT)

      when /\A\/add/
        handle_add(bot, message)

      when '/list'
        run_cli(bot, message, ['list'])

      when /\A\/buy/
        with_valid_id(bot, message, 'buy') { |id| run_cli(bot, message, ['buy', id]) }

      when /\A\/delete/
        with_valid_id(bot, message, 'delete') { |id| run_cli(bot, message, ['delete', id]) }

      when '/total'
        run_cli(bot, message, ['total'])

      else
        reply(bot, message, UNKNOWN_CMD)
      end
    end

    def self.main_keyboard
      Telegram::Bot::Types::ReplyKeyboardMarkup.new(
        keyboard: [
          ['📋 Список', '➕ Добавить'],
          ['💰 Итог',   '❌ Удалить'],
          ['✅ Купить']
        ],
        resize_keyboard: true
      )
    end

    def self.handle_add(bot, message)
      text  = message.text.sub(/\A\/add\s*/, '')
      parts = text.split

      if parts.size < 3
        reply(bot, message, "Формат: /add Название количество цена\nПример: /add Хлеб 1 45.90")
        return
      end

      price_str    = parts.pop
      quantity_str = parts.pop
      name         = parts.join(' ')

      unless quantity_str =~ /\A\d+\z/ && price_str =~ /\A\d+(\.\d+)?\z/
        reply(bot, message, 'Ошибка: количество – целое число, цена – число (например, 2 и 45.99)')
        return
      end

      run_cli(bot, message, ['add', name, '--quantity', quantity_str, '--price', price_str])
    end

    def self.run_cli(bot, message, args)
      file      = user_file(message)
      full_args = args + ['--file', file]

      output = safe_capture_stdout { ShoppingListManager::CLI.run(full_args) }

      reply(bot, message, output.empty? ? 'Готово ✅' : output)
    rescue ShoppingListManager::Error => e
      # Ожидаемые ошибки бизнес-логики — показываем пользователю
      reply(bot, message, "Ошибка: #{e.message}")
    rescue StandardError => e
      # Неожиданные ошибки — логируем полностью, пользователю показываем кратко
      warn "[ERROR] #{e.class}: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
      reply(bot, message, 'Что-то пошло не так. Попробуй ещё раз.')
    end

    # Парсит ID из команды вида "/buy 3". Если ID невалиден — отвечает и возвращает nil.
    def self.with_valid_id(bot, message, command)
      id = message.text.split[1]

      if id.nil? || !id.match?(/\A\d+\z/)
        reply(bot, message, format(ID_FORMAT_ERR, cmd: command))
        return
      end

      yield id
    end

    # Персональный файл данных для каждого пользователя
    def self.user_file(message)
      id = message.from&.id || message.chat.id
      format(FILE_PATTERN, id: id)
    end

    # Отправка сообщения с клавиатурой
    def self.reply(bot, message, text)
      bot.api.send_message(
        chat_id:      message.chat.id,
        text:         text,
        reply_markup: main_keyboard
      )
    end

    # Потокобезопасный перехват stdout через IO.pipe вместо замены $stdout глобально
    def self.safe_capture_stdout
      rd, wr = IO.pipe
      old_stdout = $stdout
      $stdout = wr

      yield

      wr.close
      rd.read
    ensure
      $stdout = old_stdout
      wr.close rescue nil
      rd.close rescue nil
    end

    private_class_method :handle_add, :run_cli, :with_valid_id,
                         :user_file, :reply, :safe_capture_stdout
  end
end