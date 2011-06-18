require "spec_helper"

describe "Nordea::ExchangeRates" do
  before(:each) do
    stub_request(:get, "http://service.nordea.com/nordea-openpages/fi/lists/currency/elelctronicExchangeFI.dat").
             to_return(:status => 200, :body => SampleData.raw)
    @exchange_rates = Nordea::ExchangeRates.new
  end

  context "#lines" do
    it "returns the raw data as an array of lines" do
      lines = @exchange_rates.send(:lines)
      lines.should be_kind_of(Array)
      lines.count.should == 221
    end
  end
end