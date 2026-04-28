# frozen_string_literal: true

require 'stringio'
require 'shopping_list_manager'

module Bot
  module Commands
    class Base
      def initialize(bot, message)
        @bot     = bot
        @message = message
      end

      def handle
        raise NotImplementedError, "#{self.class}#handle не реализован"
      end

      private

      def send_message(text)
        @bot.api.send_message(chat_id: @message.chat.id, text: text)
      end

      def run_cli(args)
        user_id  = @message.from&.id || @message.chat.id
        Dir.mkdir('data') unless Dir.exist?('data')
        file     = "data/data_#{user_id}.json"
        full_args = args + ['--file', file]

        output = capture_stdout { ShoppingListManager::CLI.run(full_args) }
        send_message(output.empty? ? 'Готово ✅' : output)
      rescue StandardError => e
        send_message("Ошибка: #{e.message}")
      end

      def capture_stdout
        old_stdout = $stdout
        $stdout    = StringIO.new
        yield
        $stdout.string
      ensure
        $stdout = old_stdout
      end
    end
  end
end
