# frozen_string_literal: true

require_relative 'base'
require_relative 'start'
require_relative 'add'
require_relative 'list'
require_relative 'id_command'
require_relative 'total'
require_relative 'unknown'

module Bot
  module Commands
    ROUTES = {
      %r{^/(start|help)$} => Start,
      %r{^/add}           => Add,
      %r{^/list$}         => List,
      %r{^/buy}           => Buy,
      %r{^/delete}        => Delete,
      %r{^/total$}        => Total,
    }.freeze

    def self.handle(bot, message)
      return if message.text.nil? || message.text.empty?

      klass = ROUTES.find { |pattern, _| message.text.match?(pattern) }&.last
      klass ||= Unknown

      klass.new(bot, message).handle
    end
  end
end