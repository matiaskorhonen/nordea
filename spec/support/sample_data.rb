# encoding: UTF-8
require "yaml"

module SampleData
  CURRENCIES = YAML.load(File.open(File.expand_path("../sample_currencies.yml", __FILE__), "r"))
  
  def self.raw
    File.open(File.expand_path("../sample_electronic.dat", __FILE__), "r")
  end

  def self.currencies
    CURRENCIES
  end
  
  def self.get_rate(currency)
    CURRENCIES[currency][:middle_rate_for_commercial_transactions]
  end
end