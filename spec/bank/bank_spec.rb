require "spec_helper"

describe "Nordea::Bank" do
  let(:bank) do
    Nordea::Bank.new
  end

  before(:each) do
    stub_request(:get, "http://openpages.nordea.com/fi/lists/currency/elelctronicExchangeFI.dat").
             to_return(:status => 200, :body => SampleData.raw)
    Money.default_bank = bank
  end

  describe "#exchange" do
    it "returns the correct exchange rates" do
      bank.known_currencies.each do |currency|
        cents = bank.exchange(100, "EUR", currency).cents
        expect(cents).to eq (SampleData.get_rate(currency) * 100).round
      end
    end
  end

  describe "#exchange_with" do
    it "returns the correct exchange rates" do
      bank.known_currencies.each do |currency|
        cents = bank.exchange_with(Money.new(100, "EUR"), currency).cents
        expect(cents).to eq (SampleData.get_rate(currency) * 100).round
      end
    end
  end

  describe "#exchange_rates" do
    it "is an instance of Nordea::ExchangeRates" do
      expect(bank.exchange_rates).to be_an_instance_of(Nordea::ExchangeRates)
    end
  end
end
