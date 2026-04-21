# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/bot/commands'


RSpec.describe Bot::Commands do
  let(:bot) { instance_double('Telegram::Bot::Client') }
  let(:api) { double('api') }
  let(:message) { instance_double('Telegram::Bot::Types::Message', text: text, chat: chat, from: from) }
  let(:chat) { instance_double('Telegram::Bot::Types::Chat', id: 123) }
  let(:from) { instance_double('Telegram::Bot::Types::User', id: 456) }

  before do
    allow(bot).to receive(:api).and_return(api)
    allow(api).to receive(:send_message)
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
        expect(described_class).to receive(:run_cli).with(
          bot, message,
          ['add', 'Молоко', '--quantity', '2', '--price', '89.90']
        )
        described_class.handle(bot, message)
      end
    end

    context 'недостаточно аргументов' do
      let(:text) { '/add Хлеб' }

      it 'отправляет сообщение об ошибке' do
        expect(api).to receive(:send_message).with(chat_id: 123, text: /Формат:/)
        described_class.handle(bot, message)
      end
    end
  end

  describe '/list' do
    let(:text) { '/list' }

    it 'вызывает run_cli с list' do
      expect(described_class).to receive(:run_cli).with(bot, message, ['list'])
      described_class.handle(bot, message)
    end
  end

  describe '/buy' do
    let(:text) { '/buy 1' }

    it 'вызывает run_cli с buy' do
      expect(described_class).to receive(:run_cli).with(bot, message, %w[buy 1])
      described_class.handle(bot, message)
    end
  end

  describe '/delete' do
    let(:text) { '/delete 1' }

    it 'вызывает run_cli с delete' do
      expect(described_class).to receive(:run_cli).with(bot, message, %w[delete 1])
      described_class.handle(bot, message)
    end
  end

  describe '/total' do
    let(:text) { '/total' }

    it 'вызывает run_cli с total' do
      expect(described_class).to receive(:run_cli).with(bot, message, ['total'])
      described_class.handle(bot, message)
    end
  end

  describe 'unknown command' do
    let(:text) { '/unknown' }

    it 'отправляет сообщение об ошибке' do
      expect(api).to receive(:send_message).with(chat_id: 123, text: /Неизвестная/)
      described_class.handle(bot, message)
    end
  end

  describe 'empty text' do
    let(:text) { nil }

    it 'не падает' do
      expect { described_class.handle(bot, message) }.not_to raise_error
    end
  end
end
