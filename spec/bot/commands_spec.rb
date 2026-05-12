# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe Bot::Commands do
  # Helpers for building test doubles
  let(:bot) { instance_double(Telegram::Bot::Client) }
  let(:api) { instance_double(Telegram::Bot::Api) }

  let(:chat) { instance_double(Telegram::Bot::Types::Chat, id: 123) }
  let(:user) { instance_double(Telegram::Bot::Types::User, id: 456) }

  let(:message) do
    instance_double(Telegram::Bot::Types::Message,
                    text: message_text,
                    chat: chat,
                    from: user,
                    message_id: 789)
  end

  let(:message_text) { raise 'Define message_text in context' }

  before do
    allow(bot).to receive(:api).and_return(api)

    # Stub all outgoing API methods
    allow(api).to receive(:send_message)
    allow(api).to receive(:edit_message_reply_markup)
    allow(api).to receive(:edit_message_text)
    allow(api).to receive(:answer_callback_query)

    # Prevent real filesystem interactions
    allow(Dir).to receive(:exist?).with('data').and_return(true)
    allow(Dir).to receive(:mkdir)

    # Stub ShoppingListManager::CLI to do nothing by default
    allow(ShoppingListManager::CLI).to receive(:run)
  end

  describe '.handle' do
    subject(:handle_message) { described_class.handle(bot, message) }

    before do
      # Let each context define message_text and expectations on the command
    end

    context 'with /start' do
      let(:message_text) { '/start' }

      it 'routes to Start' do
        start_cmd = instance_double(Bot::Commands::Start)
        expect(Bot::Commands::Start).to receive(:new).with(bot, message).and_return(start_cmd)
        expect(start_cmd).to receive(:handle)
        handle_message
      end
    end

    context 'with /help' do
      let(:message_text) { '/help' }
      it 'routes to Start' do
        start_cmd = instance_double(Bot::Commands::Start)
        expect(Bot::Commands::Start).to receive(:new).with(bot, message).and_return(start_cmd)
        expect(start_cmd).to receive(:handle)
        handle_message
      end
    end

    context 'with /add ...' do
      let(:message_text) { '/add Хлеб 1 45.50' }
      it 'routes to Add' do
        add_cmd = instance_double(Bot::Commands::Add)
        expect(Bot::Commands::Add).to receive(:new).with(bot, message).and_return(add_cmd)
        expect(add_cmd).to receive(:handle)
        handle_message
      end
    end

    context 'with /list' do
      let(:message_text) { '/list' }
      it 'routes to List' do
        list_cmd = instance_double(Bot::Commands::List)
        expect(Bot::Commands::List).to receive(:new).with(bot, message).and_return(list_cmd)
        expect(list_cmd).to receive(:handle)
        handle_message
      end
    end

    context 'with /buy 2' do
      let(:message_text) { '/buy 2' }
      it 'routes to Buy' do
        buy_cmd = instance_double(Bot::Commands::Buy)
        expect(Bot::Commands::Buy).to receive(:new).with(bot, message).and_return(buy_cmd)
        expect(buy_cmd).to receive(:handle)
        handle_message
      end
    end

    context 'with /delete 3' do
      let(:message_text) { '/delete 3' }
      it 'routes to Delete' do
        delete_cmd = instance_double(Bot::Commands::Delete)
        expect(Bot::Commands::Delete).to receive(:new).with(bot, message).and_return(delete_cmd)
        expect(delete_cmd).to receive(:handle)
        handle_message
      end
    end

    context 'with /total' do
      let(:message_text) { '/total' }
      it 'routes to Total' do
        total_cmd = instance_double(Bot::Commands::Total)
        expect(Bot::Commands::Total).to receive(:new).with(bot, message).and_return(total_cmd)
        expect(total_cmd).to receive(:handle)
        handle_message
      end
    end

    context 'with "📋 Список"' do
      let(:message_text) { '📋 Список' }
      it 'routes to List' do
        list_cmd = instance_double(Bot::Commands::List)
        expect(Bot::Commands::List).to receive(:new).with(bot, message).and_return(list_cmd)
        expect(list_cmd).to receive(:handle)
        handle_message
      end
    end

    context 'with "💰 Итого"' do
      let(:message_text) { '💰 Итого' }
      it 'routes to Total' do
        total_cmd = instance_double(Bot::Commands::Total)
        expect(Bot::Commands::Total).to receive(:new).with(bot, message).and_return(total_cmd)
        expect(total_cmd).to receive(:handle)
        handle_message
      end
    end

    context 'with "➕ Добавить товар"' do
      let(:message_text) { '➕ Добавить товар' }
      it 'routes to Add' do
        add_cmd = instance_double(Bot::Commands::Add)
        expect(Bot::Commands::Add).to receive(:new).with(bot, message).and_return(add_cmd)
        expect(add_cmd).to receive(:handle)
        handle_message
      end
    end

    context 'with "🗑 Удалить товар"' do
      let(:message_text) { '🗑 Удалить товар' }
      it 'routes to DeletePrompt' do
        prompt_cmd = instance_double(Bot::Commands::DeletePrompt)
        expect(Bot::Commands::DeletePrompt).to receive(:new).with(bot, message).and_return(prompt_cmd)
        expect(prompt_cmd).to receive(:handle)
        handle_message
      end
    end

    context 'with "❓ Помощь"' do
      let(:message_text) { '❓ Помощь' }
      it 'routes to Start' do
        start_cmd = instance_double(Bot::Commands::Start)
        expect(Bot::Commands::Start).to receive(:new).with(bot, message).and_return(start_cmd)
        expect(start_cmd).to receive(:handle)
        handle_message
      end
    end

    context 'with an unknown command' do
      let(:message_text) { '/some_unknown_command' }
      it 'routes to Unknown' do
        unknown_cmd = instance_double(Bot::Commands::Unknown)
        expect(Bot::Commands::Unknown).to receive(:new).with(bot, message).and_return(unknown_cmd)
        expect(unknown_cmd).to receive(:handle)
        handle_message
      end
    end

    context 'with empty text' do
      let(:message_text) { '' }
      it 'does nothing' do
        # handle returns early if text empty
        expect(Bot::Commands::Start).not_to receive(:new)
        expect(Bot::Commands::Unknown).not_to receive(:new)
        handle_message
      end
    end

    context 'with nil text' do
      let(:message_text) { nil }
      it 'does nothing' do
        expect(Bot::Commands::Start).not_to receive(:new)
        expect(Bot::Commands::Unknown).not_to receive(:new)
        handle_message
      end
    end
  end

  describe '.handle_callback' do
    let(:query) do
      instance_double(Telegram::Bot::Types::CallbackQuery,
                      id: 'cb_id',
                      data: 'buy:1',
                      message: message,
                      from: user)
    end

    it 'delegates to CallbackHandler' do
      handler = instance_double(Bot::Commands::CallbackHandler)
      expect(Bot::Commands::CallbackHandler).to receive(:new).with(bot, query).and_return(handler)
      expect(handler).to receive(:handle)
      described_class.handle_callback(bot, query)
    end
  end

  # --- Individual command classes ---

  shared_examples 'a command sending a message' do |expected_text_part|
    it 'sends a message containing expected text' do
      expect(api).to receive(:send_message).with(
        hash_including(text: a_string_matching(/#{Regexp.escape(expected_text_part)}/i))
      )
      subject
    end
  end

  describe Bot::Commands::Start do
    subject(:command) { Bot::Commands::Start.new(bot, message) }

    let(:message_text) { '/start' }

    it 'sends the help text with the main keyboard' do
      expect(api).to receive(:send_message).with(
        chat_id: 123,
        text:    include('Привет! Я бот для списка покупок'),
        reply_markup: kind_of(Telegram::Bot::Types::ReplyKeyboardMarkup)
      )
      command.handle
    end
  end

  describe Bot::Commands::Add do
    subject(:command) { Bot::Commands::Add.new(bot, message) }

    context 'with valid input via /add' do
      let(:message_text) { '/add Хлеб 1 45.90' }

      before do
        allow(ShoppingListManager::CLI).to receive(:run) do |args|
          # Simulate CLI output
          _, _ = args # args will be something like ['add', 'Хлеб', '--quantity', '1', '--price', '45.90', '--file', ...]
        end
      end

      it 'calls CLI with the correct arguments' do
        expect(ShoppingListManager::CLI).to receive(:run) do |args|
          expect(args[0]).to eq('add')
          expect(args[1]).to eq('Хлеб')
          expect(args).to include('--quantity', '1', '--price', '45.90')
        end
        command.handle
      end

      it 'sends success message if output is empty' do
        allow(ShoppingListManager::CLI).to receive(:run)
        expect(api).to receive(:send_message).with(
          hash_including(text: '✅ Готово')
        )
        command.handle
      end
    end

    context 'with valid input via button' do
      let(:message_text) { '➕ Добавить товар Хлеб 2 50' }

      it 'strips the button prefix and processes' do
        expect(ShoppingListManager::CLI).to receive(:run) do |args|
          expect(args).to include('Хлеб', '--quantity', '2', '--price', '50')
        end
        command.handle
      end
    end

    context 'with too few arguments' do
      let(:message_text) { '/add Хлеб 1' }

      it 'sends format hint' do
        expect(api).to receive(:send_message).with(
          hash_including(text: /Формат/)
        )
        command.handle
      end
    end

    context 'with invalid quantity (not integer)' do
      let(:message_text) { '/add Хлеб 1.5 50' }

      it 'sends error about quantity and price format' do
        expect(api).to receive(:send_message).with(
          hash_including(text: /❌ Количество — целое число/)
        )
        command.handle
      end
    end

    context 'with invalid price (letters)' do
      let(:message_text) { '/add Хлеб 1 abc' }

      it 'sends format error' do
        expect(api).to receive(:send_message).with(
          hash_including(text: /❌ Количество — целое число/)
        )
        command.handle
      end
    end

    context 'when CLI raises an error' do
      let(:message_text) { '/add Хлеб 1 50' }

      before do
        allow(ShoppingListManager::CLI).to receive(:run).and_raise(StandardError, 'Some error')
      end

      it 'sends error message' do
        expect(api).to receive(:send_message).with(
          hash_including(text: /❌ Ошибка: Some error/)
        )
        command.handle
      end
    end
  end

  describe Bot::Commands::List do
    subject(:command) { Bot::Commands::List.new(bot, message) }

    before do
      allow(api).to receive(:send_message)
    end

    context 'when the list is empty' do
      let(:message_text) { '/list' }

      before do
        allow(ShoppingListManager::CLI).to receive(:run) do |_args|
          # No output
        end
      end

      it 'sends an empty list message' do
        expect(api).to receive(:send_message).with(
          hash_including(text: /Список пуст/)
        )
        command.handle
      end
    end

    context 'when the list has items' do
      let(:message_text) { '/list' }

      before do
        # Simulate CLI output with summary and item lines
        allow(ShoppingListManager::CLI).to receive(:run) do |_args|
          $stdout.puts "🛒 Список покупок (всего: 2)"
          $stdout.puts "1. Хлеб x1 — 45.00₽"
          $stdout.puts "2. Молоко x2 — 89.00₽"
          $stdout.puts "Итого: 223.00₽"
        end
      end

      it 'sends summary lines as one message' do
        expect(api).to receive(:send_message).with(
          hash_including(text: "🛒 Список покупок (всего: 2)\nИтого: 223.00₽")
        )
        command.handle
      end

      it 'sends each item as separate message with inline keyboard' do
        # Item lines: "1. Хлеб x1 — 45.00₽"
        expect(api).to receive(:send_message).with(
          chat_id: 123,
          text:    '1. Хлеб x1 — 45.00₽',
          reply_markup: kind_of(Telegram::Bot::Types::InlineKeyboardMarkup)
        )
        expect(api).to receive(:send_message).with(
          chat_id: 123,
          text:    '2. Молоко x2 — 89.00₽',
          reply_markup: kind_of(Telegram::Bot::Types::InlineKeyboardMarkup)
        )
        command.handle
      end

      it 'includes buy and delete buttons in inline keyboard' do
        expect(api).to receive(:send_message) do |params|
          if params[:text].start_with?('1.')
            markup = params[:reply_markup]
            buttons = markup.inline_keyboard.first
            expect(buttons.map(&:text)).to contain_exactly('✅ Купить', '🗑 Удалить')
            expect(buttons.map(&:callback_data)).to contain_exactly('buy:1', 'delete:1')
          end
        end.at_least(:once)
        command.handle
      end
    end
  end

  describe Bot::Commands::Total do
    subject(:command) { Bot::Commands::Total.new(bot, message) }

    let(:message_text) { '/total' }

    it 'calls CLI total command and sends result' do
      allow(ShoppingListManager::CLI).to receive(:run) do |args|
        $stdout.puts 'Общая стоимость: 500₽'
      end

      expect(api).to receive(:send_message).with(
        hash_including(text: 'Общая стоимость: 500₽')
      )
      command.handle
    end
  end

  describe Bot::Commands::DeletePrompt do
    subject(:command) { Bot::Commands::DeletePrompt.new(bot, message) }

    let(:message_text) { '🗑 Удалить товар' }

    it 'sends a help message about deletion' do
      expect(api).to receive(:send_message).with(
        hash_including(text: /🗑 \*Удаление товара\*/)
      )
      command.handle
    end
  end

  describe Bot::Commands::Buy do
    subject(:command) { Bot::Commands::Buy.new(bot, message) }

    context 'with valid ID' do
      let(:message_text) { '/buy 5' }

      it 'calls CLI buy with ID' do
        expect(ShoppingListManager::CLI).to receive(:run) do |args|
          expect(args).to eq(['buy', '5', '--file', 'data/data_456.json'])
        end
        command.handle
      end

      it 'sends the output' do
        allow(ShoppingListManager::CLI).to receive(:run) { $stdout.puts 'Помечено как купленное' }
        expect(api).to receive(:send_message).with(
          hash_including(text: 'Помечено как купленное')
        )
        command.handle
      end
    end

    context 'without ID' do
      let(:message_text) { '/buy' }

      it 'sends usage hint' do
        expect(api).to receive(:send_message).with(
          hash_including(text: 'Укажите ID товара: /buy 2')
        )
        command.handle
      end
    end

    context 'with non-numeric ID' do
      let(:message_text) { '/buy abc' }

      it 'sends usage hint' do
        expect(api).to receive(:send_message).with(
          hash_including(text: 'Укажите ID товара: /buy 2')
        )
        command.handle
      end
    end
  end

  describe Bot::Commands::Delete do
    subject(:command) { Bot::Commands::Delete.new(bot, message) }

    context 'with valid ID' do
      let(:message_text) { '/delete 3' }

      it 'calls CLI delete with ID' do
        expect(ShoppingListManager::CLI).to receive(:run) do |args|
          expect(args).to eq(['delete', '3', '--file', 'data/data_456.json'])
        end
        command.handle
      end
    end

    context 'without ID' do
      let(:message_text) { '/delete' }

      it 'sends usage hint' do
        expect(api).to receive(:send_message).with(
          hash_including(text: 'Укажите ID товара: /delete 3')
        )
        command.handle
      end
    end
  end

  describe Bot::Commands::Unknown do
    subject(:command) { Bot::Commands::Unknown.new(bot, message) }

    let(:message_text) { '/unknown' }

    it 'sends "Неизвестная команда"' do
      expect(api).to receive(:send_message).with(
        hash_including(text: 'Неизвестная команда')
      )
      command.handle
    end
  end

  describe Bot::Commands::CallbackHandler do
    let(:query) do
      instance_double(Telegram::Bot::Types::CallbackQuery,
                      id: 'qid123',
                      data: callback_data,
                      message: message,
                      from: user)
    end
    let(:message_text) { '1. Хлеб x1 — 45.00₽' }

    subject(:handler) { Bot::Commands::CallbackHandler.new(bot, query) }

    before do
      allow(ShoppingListManager::CLI).to receive(:run)
      allow(api).to receive(:edit_message_reply_markup)
      allow(api).to receive(:edit_message_text)
      allow(api).to receive(:answer_callback_query)
    end

    shared_examples 'handles item action' do |action, success_msg, status_suffix|
      context "with #{action} action" do
        let(:callback_data) { "#{action}:42" }

        it 'calls CLI with correct arguments' do
          expect(ShoppingListManager::CLI).to receive(:run) do |args|
            expect(args).to eq([action, '42', '--file', 'data/data_456.json'])
          end
          handler.handle
        end

        it 'answers callback query with success text' do
          expect(api).to receive(:answer_callback_query).with(
            hash_including(text: success_msg, show_alert: false)
          )
          handler.handle
        end

        it 'removes inline keyboard from the message' do
          expect(api).to receive(:edit_message_reply_markup).with(
            chat_id: 123,
            message_id: 789,
            reply_markup: satisfy { |m| m.inline_keyboard.empty? }
          )
          handler.handle
        end

        it 'appends status to the message text' do
          expect(api).to receive(:edit_message_text).with(
            chat_id: 123,
            message_id: 789,
            text: message_text + status_suffix
          )
          handler.handle
        end
      end
    end

    it_behaves_like 'handles item action', 'buy', '✅ Отмечено как купленное!', ' ✅'
    it_behaves_like 'handles item action', 'delete', '🗑 Товар удалён', ' 🗑'

    context 'with unknown action' do
      let(:callback_data) { 'unknown:1' }

      it 'answers callback with "Неизвестное действие"' do
        expect(api).to receive(:answer_callback_query).with(
          hash_including(text: 'Неизвестное действие')
        )
        handler.handle
      end
    end

    context 'when edit_message fails with Telegram response error' do
      let(:callback_data) { 'buy:1' }

      before do
        allow(api).to receive(:edit_message_text).and_raise(Telegram::Bot::Exceptions::ResponseError)
      end

      it 'does not propagate the error' do
        expect { handler.handle }.not_to raise_error
      end

      it 'still answers the callback query' do
        expect(api).to receive(:answer_callback_query)
        handler.handle
      end
    end
  end
end