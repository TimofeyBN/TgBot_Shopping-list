require 'spec_helper'

RSpec.describe Bot::Commands do
  let(:bot) { instance_double('Telegram::Bot::Client') }
  let(:api) { instance_double('Telegram::Bot::Api') }
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
      expect(api).to receive(:send_message).with(chat_id: 123, text: /Привет/)
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

    context 'некорректные числа' do
      let(:text) { '/add Сыр два 120' }

      it 'отправляет сообщение об ошибке' do
        expect(api).to receive(:send_message).with(chat_id: 123, text: /Ошибка: количество должно быть/)
        described_class.handle(bot, message)
      end
    end
  end

end