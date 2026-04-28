# frozen_string_literal: true

module Bot
  module Commands
    class Unknown < Base
      def handle
        send_message('Неизвестная команда')
      end
    end
  end
end
