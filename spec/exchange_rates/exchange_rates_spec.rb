require "spec_helper"

describe "Nordea::ExchangeRates" do
  before(:each) do
    stub_request(:get, "http://service.nordea.com/nordea-openpages/fi/lists/currency/elelctronicExchangeFI.dat").
             to_return(:status => 200, :body => SampleData.raw)
    @exchange_rates = Nordea::ExchangeRates.new
  end

  context "#lines" do
    it "returns the raw data as an array of lines" do
      @exchange_rates.send(:lines).should be_kind_of(Array)
    end

    it "returns the correct number of lines" do
      @exchange_rates.send(:lines).count.should == 221
    end
  end

  context "#records_array" do
    before(:each) do
      @records = @exchange_rates.send(:records_array)
    end

    it "returns an array of hashes" do
      @records.should be_kind_of(Array)
      @records.each do |record|
        record.should be_kind_of(Hash)
      end
    end

    it "has the correct number of records" do
      @records.length.should == SampleData.currencies.length
    end

    it "has the correct data" do
      @records.each do |record|
        currency = record[:currency_iso_code]
        sample = SampleData.currencies[currency]

        record.each_pair do |key, value|
          value.should == sample[key]
        end
      end
    end
  end

  context "#headers" do
    before(:each) do
      @headers = @exchange_rates.headers
    end

    it "returns a hash" do
      @headers.should be_kind_of(Hash)
    end

    it "has the correct data" do
      @headers = @exchange_rates.headers
      @headers.each_pair do |key,value|
        value.should == SampleData.headers[key]
      end
    end
  end

  context "#fetch_data" do
    it "returns the raw data from the server if the request is successful" do
      @exchange_rates.send(:fetch_data).should == SampleData.raw.read
    end

    it "raises an exception if the request is not successful" do
      stub_request(:get, "http://service.nordea.com/nordea-openpages/fi/lists/currency/elelctronicExchangeFI.dat").
               to_return(:status => 404, :body => SampleData.raw)
      expect { @exchange_rates.send(:fetch_data) }.to raise_error Nordea::ServerError
    end
  end
end