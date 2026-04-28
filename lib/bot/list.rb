# frozen_string_literal: true

module Bot
  module Commands
    class List < Base
      def handle
        run_cli(['list'])
      end
    end
  end
end