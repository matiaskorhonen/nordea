require "spec_helper"

describe "Nordea::ExchangeRates" do
  let(:exchange_rates) do
    Nordea::ExchangeRates.new
  end

  before(:each) do
    stub_request(:get, "http://openpages.nordea.com/fi/lists/currency/elelctronicExchangeFI.dat").
             to_return(:status => 200, :body => SampleData.raw)
  end

  describe "#lines" do
    it "returns the raw data as an array of lines" do
      expect(exchange_rates.send(:lines)).to be_kind_of(Array)
    end

    it "returns the correct number of lines" do
      expect(exchange_rates.send(:lines).count).to eq 221
    end
  end

  describe "#currencies" do
    it "has the correct data" do
      currencies = exchange_rates.currencies

      expect(currencies["EUR"]).to eq SampleData.currencies["EUR"]
      expect(currencies["USD"]).to eq SampleData.currencies["USD"]
      expect(currencies["JPY"]).to eq SampleData.currencies["JPY"]
    end
  end

  describe "#records_array" do
    let(:records) do
      exchange_rates.send(:records_array)
    end

    it "returns an array of hashes" do
      expect(records).to be_kind_of(Array)
      records.each do |record|
        expect(record).to be_kind_of(Hash)
      end
    end

    it "has the correct number of records" do
      expect(records.length).to eq SampleData.currencies.length
    end
  end

  describe "#headers" do
    let(:headers) do
      exchange_rates.headers
    end

    it "returns a hash" do
      expect(headers).to be_kind_of(Hash)
    end

    it "has the correct data" do
      headers.each_pair do |key,value|
        expect(value).to eq SampleData.headers[key]
      end
    end
  end

  describe "#fetch_data" do
    it "returns the raw data from the server if the request is successful" do
      expect(exchange_rates.send(:fetch_data)).to eq SampleData.raw.read
    end

    it "raises an exception if the request is not successful" do
      stub_request(:get, "http://openpages.nordea.com/fi/lists/currency/elelctronicExchangeFI.dat").
               to_return(:status => 404, :body => SampleData.raw)
      expect { exchange_rates.send(:fetch_data) }.to raise_error Nordea::ServerError
    end
  end
end
