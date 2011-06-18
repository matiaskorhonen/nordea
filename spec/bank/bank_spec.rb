require "spec_helper"

describe "Nordea::Bank" do
  before(:each) do
    stub_request(:get, "http://service.nordea.com/nordea-openpages/fi/lists/currency/elelctronicExchangeFI.dat").
             to_return(:status => 200, :body => SampleData.raw)
    @bank = Nordea::Bank.new
    Money.default_bank = @bank
  end

  context "#exchange" do
    it "returns the correct exchange rates" do
      @bank.known_currencies.each do |currency|
        @bank.exchange(100, "EUR", currency).cents.should == (SampleData.get_rate(currency) * 100).round
      end
    end
  end

  context "#exchange_with" do
    it "returns the correct exchange rates" do
      @bank.known_currencies.each do |currency|
        @bank.exchange_with(Money.new(100, "EUR"), currency).cents.should == (SampleData.get_rate(currency) * 100).round
      end
    end
  end
end