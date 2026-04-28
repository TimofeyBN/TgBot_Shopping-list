# frozen_string_literal: true

module Bot
  module Commands
    class Total < Base
      def handle
        run_cli(['total'])
      end
    end
  end
end