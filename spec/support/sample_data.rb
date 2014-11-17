# encoding: UTF-8

require 'yaml'

module SampleData
  CURRENCIES = YAML.load_file(File.open(File.expand_path('../sample_currencies.yml', __FILE__), 'r'))
  HEADERS    = YAML.load_file(File.open(File.expand_path('../sample_headers.yml', __FILE__), 'r'))
  extend self

  class << self
    def raw
      File.open(File.expand_path('../sample_electronic.dat', __FILE__), 'r')
    end

    def currencies
      CURRENCIES
    end

    def get_rate(currency)
      CURRENCIES[currency][:middle_rate_for_commercial_transactions]
    end

    def headers
      HEADERS
    end
  end
end
