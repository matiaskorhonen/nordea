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

    # Get updated rates from the Nordea server
    #
    # Forces an update of the exchange rates
    #
    # @return [Hash] rates available
    def update_rates
      currencies(true).each_pair do |currency, data|
        rate = data[:middle_rate_for_commercial_transactions]
        add_rate("EUR", currency, rate) if known_currencies.include?(currency)
      end
      rates
    end

    # Exchange from one currency to another
    #
    # @example
    #   nordea_bank = Nordea::Bank.new
    #   nordea_bank.exchange(100, "EUR", "USD")
    #
    # @param [Integer] cents the amount for the conversion in cents, or equivalent
    # @param [String] from_currency the source currency
    # @param [String] to_currency the target currency
    # @return [Money] the result of the conversion
    def exchange(cents, from_currency = "EUR", to_currency = "EUR")
      exchange_with(Money.new(cents, from_currency), to_currency)
    end

    # Exchanges the given +Money+ object to a new +Money+ object in
    # +to_currency+.
    #
    # @example
    #   nordea_bank = Nordea::Bank.new
    #   nordea_bank.exchange_with(Money.new(100, "CAD"), "USD")
    #
    # @param [Money] from the Money object from which to convert
    # @param [String] to_currency the ISO code for the target currency
    # @return [Money] the new Money object in the target currency
    def exchange_with(from, to_currency)
      rate = get_rate(from.currency, to_currency)
      unless rate
        from_base_rate = get_rate("EUR", from.currency)
        to_base_rate = get_rate("EUR", to_currency)
        rate = to_base_rate / from_base_rate
      end
      Money.new((from.cents * rate).round, to_currency)
    end

    # Initialize or use an existing Nordea::ExchangeRates object
    #
    # @return [ExchangeRates] an instance of Nordea::ExchangeRates
    def exchange_rates
      @exchange_rates ||= Nordea::ExchangeRates.new
    end

    # Get the currency data from Nordea
    #
    # @param [Boolean] force force an update of the currency data
    # @return [Hash] Data for all the currencies and rates from Nordea
    def currencies(force = false)
      exchange_rates.currencies(force)
    end
    
    # List all currencies known to the money gem
    #
    # @return [Array<String>] ISO currency codes
    def money_currencies
      Money::Currency.table.keys.map { |c| c.to_s.upcase }
    end

    # List currencies found in the Money gem *and* the Nordea currency data
    #
    # @return [Array<String>]  ISO currency codes
    def known_currencies
      @known_currencies = money_currencies & exchange_rates.currencies.keys
    end
  end
end