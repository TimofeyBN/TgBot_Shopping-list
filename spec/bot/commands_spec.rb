# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/bot/commands'

RSpec.describe Bot::Commands do
  let(:bot)     { instance_double('Telegram::Bot::Client') }
  let(:api)     { double('api') }
  let(:message) { instance_double('Telegram::Bot::Types::Message', text: text, chat: chat, from: from) }
  let(:chat)    { instance_double('Telegram::Bot::Types::Chat', id: 123) }
  let(:from)    { instance_double('Telegram::Bot::Types::User', id: 456) }

  before do
    allow(bot).to receive(:api).and_return(api)
    allow(api).to receive(:send_message)
    # Глушим CLI чтобы не трогать файловую систему
    allow(ShoppingListManager::CLI).to receive(:run)
  end

  describe '/start' do
    let(:text) { '/start' }

    it 'отправляет приветственное сообщение' do
      expect(api).to receive(:send_message).with(chat_id: 123, text: /Я бот для списка покупок/i)
      described_class.handle(bot, message)
    end
  end

  describe '/add' do
    context 'корректный ввод' do
      let(:text) { '/add Молоко 2 89.90' }

      it 'вызывает CLI с правильными аргументами' do
        expect(ShoppingListManager::CLI).to receive(:run).with(
          ['add', 'Молоко', '--quantity', '2', '--price', '89.90', '--file', 'data_456.json']
        )
        described_class.handle(bot, message)
      end
    end

    context 'недостаточно аргументов' do
      let(:text) { '/add Хлеб' }

      it 'отправляет сообщение об ошибке формата' do
        expect(api).to receive(:send_message).with(chat_id: 123, text: /Формат:/)
        described_class.handle(bot, message)
      end

      it 'не вызывает CLI' do
        expect(ShoppingListManager::CLI).not_to receive(:run)
        described_class.handle(bot, message)
      end
    end

    context 'некорректное количество' do
      let(:text) { '/add Хлеб abc 45.00' }

      it 'отправляет сообщение об ошибке валидации' do
        expect(api).to receive(:send_message).with(chat_id: 123, text: /количество/)
        described_class.handle(bot, message)
      end
    end
  end

  describe '/list' do
    let(:text) { '/list' }

    it 'вызывает CLI с аргументом list' do
      expect(ShoppingListManager::CLI).to receive(:run).with(
        ['list', '--file', 'data_456.json']
      )
      described_class.handle(bot, message)
    end
  end

  describe '/buy' do
    context 'с корректным ID' do
      let(:text) { '/buy 1' }

      it 'вызывает CLI с аргументом buy и ID' do
        expect(ShoppingListManager::CLI).to receive(:run).with(
          ['buy', '1', '--file', 'data_456.json']
        )
        described_class.handle(bot, message)
      end
    end

    context 'без ID' do
      let(:text) { '/buy' }

      it 'отправляет подсказку об использовании' do
        expect(api).to receive(:send_message).with(chat_id: 123, text: /\/buy \d/)
        described_class.handle(bot, message)
      end
    end
  end

  describe '/delete' do
    context 'с корректным ID' do
      let(:text) { '/delete 3' }

      it 'вызывает CLI с аргументом delete и ID' do
        expect(ShoppingListManager::CLI).to receive(:run).with(
          ['delete', '3', '--file', 'data_456.json']
        )
        described_class.handle(bot, message)
      end
    end

    context 'без ID' do
      let(:text) { '/delete' }

      it 'отправляет подсказку об использовании' do
        expect(api).to receive(:send_message).with(chat_id: 123, text: /\/delete \d/)
        described_class.handle(bot, message)
      end
    end
  end

  describe '/total' do
    let(:text) { '/total' }

    it 'вызывает CLI с аргументом total' do
      expect(ShoppingListManager::CLI).to receive(:run).with(
        ['total', '--file', 'data_456.json']
      )
      described_class.handle(bot, message)
    end
  end

  describe '/help' do
    let(:text) { '/help' }

    it 'отправляет справочное сообщение' do
      expect(api).to receive(:send_message).with(chat_id: 123, text: /Я бот для списка покупок/i)
      described_class.handle(bot, message)
    end
  end

  describe 'неизвестная команда' do
    let(:text) { '/unknown' }

    it 'отправляет сообщение об ошибке' do
      expect(api).to receive(:send_message).with(chat_id: 123, text: /Неизвестная/)
      described_class.handle(bot, message)
    end
  end

  describe 'пустой текст' do
    let(:text) { nil }

    it 'не падает' do
      expect { described_class.handle(bot, message) }.not_to raise_error
    end

    it 'не вызывает CLI' do
      expect(ShoppingListManager::CLI).not_to receive(:run)
      described_class.handle(bot, message)
    end
  end

  describe 'CLI возвращает вывод' do
    let(:text) { '/list' }

    it 'отправляет вывод CLI пользователю' do
      allow(ShoppingListManager::CLI).to receive(:run) { print '1. Молоко x2 — 179.80 ₽' }
      expect(api).to receive(:send_message).with(chat_id: 123, text: '1. Молоко x2 — 179.80 ₽')
      described_class.handle(bot, message)
    end

    it 'отправляет «Готово» если CLI ничего не вывел' do
      allow(ShoppingListManager::CLI).to receive(:run) # ничего не печатает
      expect(api).to receive(:send_message).with(chat_id: 123, text: 'Готово ✅')
      described_class.handle(bot, message)
    end
  end
end