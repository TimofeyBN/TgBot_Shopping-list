# frozen_string_literal: true

require_relative 'base'
require_relative 'start'
require_relative 'add'
require_relative 'list'
require_relative 'delete_prompt'
require_relative 'id_command'
require_relative 'total'
require_relative 'unknown'
require_relative 'callback_handler'

module Bot
  module Commands
    ROUTES = {
      %r{^/(start|help)$}i          => Start,
      %r{^/add}i                    => Add,
      %r{^/list$}i                  => List,
      %r{^/buy}i                    => Buy,
      %r{^/delete}i                 => Delete,
      %r{^/total$}i                 => Total,

      # Reply-keyboard кнопки
      /^📋\s*Список$/               => List,
      /^💰\s*Итого$/                => Total,
      /^➕\s*Добавить товар$/       => Add,
      /^🗑\s*Удалить товар$/        => DeletePrompt,
      /^❓\s*Помощь$/               => Start
    }.freeze

    def self.handle(bot, message)
      return if message.text.nil? || message.text.empty?

      klass = ROUTES.find { |pattern, _| message.text.match?(pattern) }&.last
      klass ||= Unknown

      klass.new(bot, message).handle
    end

    # Обработка нажатий на inline-кнопки
    def self.handle_callback(bot, query)
      CallbackHandler.new(bot, query).handle
    end
  end
end
