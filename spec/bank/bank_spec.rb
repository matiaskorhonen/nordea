require "spec_helper"

describe "Nordea" do
  describe "::Bank" do
    before(:each) do
      stub_request(:get, "http://service.nordea.com/nordea-openpages/fi/lists/currency/elelctronicExchangeFI.dat").
               to_return(:status => 200, :body => SampleData.raw)
      @bank = Nordea::Bank.new
      Money.default_bank = @bank
    end

    it "should return the correct exchange rates using exchange" do
      @bank.known_currencies.each do |currency|
        @bank.exchange(100, "EUR", currency).cents.should == (SampleData.get_rate(currency) * 100).round
      end
    end

    it "should return the correct exchange rates using exchange_with" do
      @bank.known_currencies.each do |currency|
        @bank.exchange_with(Money.new(100, "EUR"), currency).cents.should == (SampleData.get_rate(currency) * 100).round
      end
    end
  end
end