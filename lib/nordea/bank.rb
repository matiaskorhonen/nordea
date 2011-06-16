require "money"
require "nordea/exchange_rates"

module Nordea
  class InvalidCache < StandardError ; end
  
  class Bank < Money::Bank::VariableExchange
    def exchange_rates
      exchange_rates = ExchangeRates.new
    end
    
    def update_rates
      exchange_rates(cache).each do |exchange_rate|

        add_rate("EUR", currency, rate)
      end
      add_rate("EUR", "EUR", 1)
    end
  end
end