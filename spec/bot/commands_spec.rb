# spec/bot/commands_spec.rb
require 'spec_helper'

RSpec.describe Bot::Commands do
  # Создаем заглушки для бота и API
  let(:api) { double('Api') }
  let(:bot) { double('Bot', api: api) }
  
  # Создаем имитацию сообщения Telegram
  let(:chat) { double('Chat', id: 123) }
  let(:user) { double('User', id: 123) }
  let(:message) { instance_double(Telegram::Bot::Types::Message, text: text, chat: chat, from: user) }

  before do
    # Разрешаем боту отправлять любые сообщения, чтобы тесты не падали на побочных эффектах
    allow(api).to receive(:send_message)
    # Заглушаем вызов CLI, так как команды (например, List) обращаются к нему
    allow(ShoppingListManager::CLI).to receive(:run)
  end

  describe '.handle' do
    context 'когда введена команда /start' do
      let(:text) { '/start' }

      it 'вызывает команду Start и отправляет приветствие' do
        # Проверяем, что класс Start инициализируется
        expect(Bot::Commands::Start).to receive(:new).with(bot, message).and_call_original
        # Проверяем, что API действительно получает вызов на отправку сообщения
        expect(api).to receive(:send_message).with(hash_including(text: /Привет/))
        
        Bot::Commands.handle(bot, message)
      end
    end

    context 'когда нажата кнопка Список' do
      let(:text) { '📋 Список' }

      it 'вызывает команду List' do
        expect(Bot::Commands::List).to receive(:new).with(bot, message).and_call_original
        # Если CLI ничего не вернул, List отправит сообщение о пустом списке
        expect(api).to receive(:send_message).with(hash_including(text: /Список пуст/))
        
        Bot::Commands.handle(bot, message)
      end
    end

    context 'когда введена неизвестная команда' do
      let(:text) { 'какая-то абракадабра' }

      it 'вызывает команду Unknown' do
        expect(Bot::Commands::Unknown).to receive(:new).with(bot, message).and_call_original
        # Unknown всегда отправляет текст о неизвестной команде
        expect(api).to receive(:send_message).with(hash_including(text: 'Неизвестная команда'))
        
        Bot::Commands.handle(bot, message)
      end
    end
  end
end