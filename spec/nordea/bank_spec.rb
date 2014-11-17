require 'spec_helper'

describe Nordea::Bank do
  let(:bank) { described_class.new }

  before :each do
    ::Money.default_bank = bank
  end

  context 'update rates from nordea' do
    before(:each) do
      stub_request(:get, 'http://openpages.nordea.com/fi/lists/currency/elelctronicExchangeFI.dat')
        .to_return(status: 200, body: SampleData.raw)
      bank.update_rates
    end

    describe '#exchange' do
      it 'returns the correct exchange rates' do
        bank.known_currencies.each do |currency|
          expect(bank.exchange(100, 'EUR', currency).cents).to eq((SampleData.get_rate(currency) * 100).round)
        end
      end
    end

    describe '#exchange_with' do
      it 'returns the correct exchange rates' do
        bank.known_currencies.each do |currency|
          expect(bank.exchange_with(Money.new(100, 'EUR'), currency).cents).to eq((SampleData.get_rate(currency) * 100).round)
        end
      end
    end
  end

  context 'load from file' do
    let(:file) { File.expand_path('../../support/cache.yml', __FILE__) }
    before :each do
      bank.update_rates(file)
    end
    describe '#exchange' do
      it 'returns the correct exchange rates' do
        bank.known_currencies.each do |currency|
          expect(bank.exchange(100, 'EUR', currency).cents).to eq((SampleData.get_rate(currency) * 100).round)
        end
      end
    end

    describe '#exchange_with' do
      it 'returns the correct exchange rates' do
        bank.known_currencies.each do |currency|
          expect(bank.exchange_with(Money.new(100, 'EUR'), currency).cents).to eq((SampleData.get_rate(currency) * 100).round)
        end
      end
    end
  end

  describe '#save_rates' do
    it 'should call dump_to_yaml' do
      expect(bank.exchange_rates).to receive(:dump_to_yaml).with('blablabla')
      bank.save_rates('blablabla')
    end
  end

  describe '#exchange_rates' do
    subject { super().exchange_rates }
    it { is_expected.to be_a(Nordea::ExchangeRates) }
  end
end
