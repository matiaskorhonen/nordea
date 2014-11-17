require 'spec_helper'

describe Nordea::ExchangeRates do
  let(:exchange_rates) { described_class.new }
  let(:nordea_request_stub) { stub_request(:get, 'http://openpages.nordea.com/fi/lists/currency/elelctronicExchangeFI.dat')
      .to_return(status: 200, body: SampleData.raw) }

  before(:each) do
    nordea_request_stub
  end

  describe '#currencies' do
    it 'has the correct data' do
      expect(exchange_rates.currencies['EUR']).to eq(SampleData.currencies['EUR'])
      expect(exchange_rates.currencies['USD']).to eq(SampleData.currencies['USD'])
      expect(exchange_rates.currencies['JPY']).to eq(SampleData.currencies['JPY'])
    end
  end

  describe '#headers' do
    let(:headers) do
      exchange_rates.headers
    end

    it 'returns a hash' do
      expect(headers).to be_kind_of(Hash)
    end

    it 'has the correct data' do
      headers.each_pair do |key, value|
        expect(value).to eq(SampleData.headers[key])
      end
    end
  end

  describe '#fetch_data' do
    it 'returns the raw data from the server if the request is successful' do
      expect(exchange_rates.send(:fetch_data)).to eq(SampleData.raw.read)
    end

    it 'raises an exception if the request is not successful' do
      stub_request(:get, 'http://openpages.nordea.com/fi/lists/currency/elelctronicExchangeFI.dat')
        .to_return(status: 404, body: SampleData.raw)
      expect { exchange_rates.send(:fetch_data) }.to raise_error Nordea::ServerError
    end
  end

  describe '#dump_to_yaml' do
    let(:file) { File.expand_path('../../../tmp/dump.yml', __FILE__) }

    before :each do
      exchange_rates.dump_to_yaml(file)
    end

    after :each do
      if ::File.exist?(file)
        ::File.unlink(file)
      end
    end

    it 'should create a file' do
      expect(::File.exist?(file))
    end
    it 'should create proper file data' do
      data = ::YAML.load_file(file)
      expect(data[:currencies]).to eq(::SampleData.currencies)
      expect(data[:headers]).to eq(::SampleData.headers)
    end
  end

  describe '#load_from_yaml' do
    let(:file) { File.expand_path('../../support/cache.yml', __FILE__) }
    before :each do
      exchange_rates.load_from_yaml(file)
    end

    it 'should load proper data from file' do
      expect(exchange_rates.currencies).to eq(::SampleData.currencies)
      expect(exchange_rates.headers).to eq(::SampleData.headers)
    end

    it 'should not make requests to Nordea' do
      expect(nordea_request_stub).to_not have_been_made
    end
  end
end
