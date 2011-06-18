require "money"
require "nordea/exchange_rates"

module Nordea
  # Bank implementation for use with the Money gem.
  #
  # @example
  #   nordea_bank = Nordea::Bank.new
  #   Money.default_bank =  nordea_bank
  #   nordea_bank.exchange(100, "EUR", "USD")
  #   Money.us_dollar(100).exchange_to("ZAR")
  #   nordea_bank.exchange_with(Money.new(100, "CAD"), "USD")
  class Bank < Money::Bank::VariableExchange
    def initialize
      super
      update_rates
    end

    def update_rates
      currencies.each_pair do |currency, data|
        puts data.inspect
        rate = data[:middle_rate_for_commercial_transactions]
        add_rate("EUR", currency, rate) if known_currencies.include?(currency)
      end
    end

    def exchange(cents, from_currency, to_currency)
      exchange_with(Money.new(cents, from_currency), to_currency)
    end

    def exchange_with(from, to_currency)
      rate = get_rate(from.currency, to_currency)
      unless rate
        from_base_rate = get_rate("EUR", from.currency)
        to_base_rate = get_rate("EUR", to_currency)
        rate = to_base_rate / from_base_rate
      end
      Money.new((from.cents * rate).round, to_currency)
    end

    def exchange_rates
      @exchange_rates ||= Nordea::ExchangeRates.new
    end

    def currencies(force = true)
      exchange_rates.currencies(force)
    end
    
    def money_currencies
      Money::Currency::TABLE.keys.map { |c| c.to_s.upcase }
    end

    def known_currencies
      @known_currencies = money_currencies & exchange_rates.currencies.keys
    end
  end
end