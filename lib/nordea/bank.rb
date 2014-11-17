require 'money'
require 'nordea/exchange_rates'
require 'forwardable'

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
    extend ::Forwardable

    def_delegators :exchange_rates, :currencies, :headers, :load_from_yaml, :dump_to_yaml, :force_update

    # Get updated rates from the Nordea server
    #
    # @param [Boolean] force Force or not an update of the exchange rates from Nordea bank
    # @return [Hash] rates available
    def update_rates(file = nil)
      hash_data = if file && ::File.exist?(file)
                    load_from_yaml(file)
                  else
                    force_update
                    currencies
                  end
      @mutex.synchronize do
        hash_data.each_pair do |currency, data|
          rate = data[:middle_rate_for_commercial_transactions]
          set_rate('EUR', currency, rate, without_mutex: true) if known_currencies.include?(currency)
        end
      end

      rates
    end

    # Save rates to the cache file
    def save_rates(file)
      dump_to_yaml(file)
    end

    # Exchange from one currency to another
    #
    # @example
    #   nordea_bank = Nordea::Bank.new
    #   nordea_bank.update_rates
    #   nordea_bank.exchange(100, "EUR", "USD")
    #
    # @param [Integer] cents the amount for the conversion in cents, or equivalent
    # @param [String] from_currency the source currency
    # @param [String] to_currency the target currency
    # @return [Money] the result of the conversion
    def exchange(cents, from_currency = 'EUR', to_currency = 'EUR')
      fail 'Load rates first' unless @rates.size > 0
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
        from_base_rate = get_rate('EUR', from.currency)
        to_base_rate   = get_rate('EUR', to_currency)
        rate           = to_base_rate / from_base_rate
      end
      ::Money.new((from.cents * rate).round, to_currency)
    end

    # Initialize or use an existing Nordea::ExchangeRates object
    #
    # @return [ExchangeRates] an instance of Nordea::ExchangeRates
    def exchange_rates
      @exchange_rates ||= Nordea::ExchangeRates.new
    end

    # List all currencies known to the money gem
    #
    # @return [Array<String>] ISO currency codes
    def money_currencies
      ::Money::Currency.table.keys.map { |c| c.to_s.upcase }
    end

    # List currencies found in the Money gem *and* the Nordea currency data
    #
    # @return [Array<String>]  ISO currency codes
    def known_currencies
      @known_currencies ||= money_currencies & currencies.keys
    end
  end
end
