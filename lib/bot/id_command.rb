# frozen_string_literal: true

module Bot
  module Commands
    # Общий предок для команд, требующих числовой ID
    class IdCommand < Base
      def handle
        id = @message.text.split[1]

        if id.nil? || id !~ /^\d+$/
          send_message(usage_hint)
          return
        end

        run_cli([cli_command, id])
      end

      private

      def cli_command = raise NotImplementedError
      def usage_hint  = raise NotImplementedError
    end

    class Buy < IdCommand
      private
      def cli_command = 'buy'
      def usage_hint  = 'Укажите ID товара: /buy 2'
    end

    class Delete < IdCommand
      private
      def cli_command = 'delete'
      def usage_hint  = 'Укажите ID товара: /delete 3'
    end
  end
end