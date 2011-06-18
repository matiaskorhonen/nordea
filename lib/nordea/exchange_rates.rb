# encoding: UTF-8
require "net/http"
require "uri"
require "time"
require "date"

module Nordea
  # Fetch and update Excahnge rates from Nordea Bank.
  #
  # Parses the custom dataformat used by Nordea into more useful Ruby types and
  # objects.
  class ExchangeRates
    # URI to the machine readable data file.
    DATA_URI = URI::HTTP.build({
      :host => "service.nordea.com",
      :path => "/nordea-openpages/fi/lists/currency/elelctronicExchangeFI.dat"
    })

    # Hash keys for key-value pairs that should be converted into floats.
    FLOAT_KEYS = [
      :middle_rate_for_commercial_transactions,
      :buying_rate_for_commercial_transactions,
      :selling_rate_for_commercial_transactions,
      :buying_rate_for_cash,
      :selling_rate_for_cash
    ]

    # Initialize a new Nordea::ExchangeRates object.
    def initialize
    end

    # The batch headers
    #
    # @return [Hash] key-value pairs
    # @param [Boolean] force force update
    def headers(force = false)
      header_line = lines(force).first

      headers = {
        :file_id       => header_line[0..3],      # File ID   = VK01
        :record_id     => header_line[4..6],      # Record ID = 000
        :change_time   => header_line[7..20],     # Exchange rate change time
        :notifications => header_line[21..140],   # Notifications
        :reserved      => header_line[141..149]   # Reserved
      }

      headers[:change_time] = Nordea.parse_time(headers[:change_time])
      headers[:notifications].strip! if headers[:notifications].respond_to? :strip!
      headers[:reserved].strip! if headers[:reserved].respond_to? :strip!
      headers
    end

    # List all currencies as a hash. Uses the currencies' ISO codes as keys.
    #
    # @example
    #   e = Nordea::ExchangeRates.new #=> #<Nordea::ExchangeRates:0x00000102102888>
    #   e.currencies["USD"] #=> {
    #   #                                      :file_id => "VK01",
    #   #                                    :record_id => "001",
    #   #                               :quotation_time => 2011-06-17 15:50:01 +0300,
    #   #                                    :rate_type => :list,
    #   #                            :currency_iso_code => "USD",
    #   #                    :counter_currency_iso_code => "EUR",
    #   #      :middle_rate_for_commercial_transactions => 1.427,
    #   #      :buying_rate_for_commercial_transactions => 1.442,
    #   #     :selling_rate_for_commercial_transactions => 1.412,
    #   #                         :buying_rate_for_cash => 1.459,
    #   #                        :selling_rate_for_cash => 1.395,
    #   #                          :direction_of_change => "-",
    #   #                      :currency_convertability => "K",
    #   #                                    :euro_area => false,
    #   #                           :euro_adoption_date => nil,
    #   #                              :currency_expiry => false,
    #   #                                     :reserved => ""
    #   # }
    #
    # @param [Boolean] force force update
    # @return [Hash] a hash off all list currency rates and their properties
    def currencies(force = false)
      hash = {}

      records_array(force).each do |record|
        hash[record[:currency_iso_code]] = record
      end

      hash
    end

    private

    # Fetches the latest machine readable currency data from the Nordea server.
    #
    # Nordea quotes exchange rates on national banking days at least three times a day:
    # * in the morning at 8.00,
    # * at noon at 12.15 and
    # * in the afternoon at 16.15 (approximate times).
    #
    # @see http://j.mp/Nordea_exchange_rates More information about Nordea exchange rates
    # @see http://j.mp/Rates_for_electronic_processing More information about the data format
    #
    # @return [String] the raw data string.
    def fetch_data
      res = Net::HTTP.start(DATA_URI.host, DATA_URI.port) do |http|
        http.get(DATA_URI.path, { "USER_AGENT" => "Nordea::Bank gem" })
      end

      if res.code =~ /2\d\d/
        res.body
      else
        raise "Nasty exception"
      end
    end

    # The raw machine readable data split into lines.
    #
    # @return [Array<String>] the raw data split into lines
    # @param [Boolean] force force update
    # @see #raw_data
    def lines(force = false)
      raw_data(force).lines.to_a
    end

    # The raw machine readable data from Nordea.
    #
    # If the data has already been fetched, it will return it. If not, a call
    # will be made to the Nordea server.
    #
    # @param [Boolean] force force update
    # @return [String] the raw data string
    # @see #fetch_data
    def raw_data(force = false)
      if force
        @raw_data = fetch_data
      else
        @raw_data ||= fetch_data
      end
    end

    # The data entries as an array of hashes with minimal processing.
    #
    # @return [Array<Hash>] Array of exchange rate records
    # @param [Boolean] force force update
    def records_array(force = false)
      all = lines(force)[1..(lines.length - 1)].map do |line|
        hash = {
          :file_id                                  => line[0..3],      # File ID (= VK01)
          :record_id                                => line[4..6],      # Record ID (= 000)
          :quotation_time                           => line[7..20],     # Quotation date
          :rate_type                                => line[21..24],    # Rate type ( 0001 = list, 0002 = valuation)
          :currency_iso_code                        => line[25..27],    # Currency ISO code
          :counter_currency_iso_code                => line[28..30],    # Counter currency ISO code (= EUR)
          :middle_rate_for_commercial_transactions  => line[31..43],    # Middle rate for commercial transactions
          :buying_rate_for_commercial_transactions  => line[44..56],    # Buying rate for commercial transactions
          :selling_rate_for_commercial_transactions => line[57..69],    # Selling rate for commercial transactions
          :buying_rate_for_cash                     => line[70..82],    # Buying rate for cash
          :selling_rate_for_cash                    => line[83..95],    # Selling rate for cash
          :direction_of_change                      => line[96..96],    # Direction of change from previous value ("+", "-" or blank)
          :currency_convertability                  => line[97..97],    # K = convertible, E = non-convertible
          :euro_area                                => line[98..98],    # 1 = euro area currency, 0 = non-euro area currency
          :euro_adoption_date                       => line[99..99],    # Euro adoption date
          :currency_expiry                          => line[100..107],  # K = in use, E = not in use
          :reserved                                 => line[108..149]   # Reserved
        }

        line_postprocess(hash)
      end

      list_rates = all.keep_if do |rate|
        rate[:rate_type] == :list
      end

      list_rates
    end

    # Converts the string values from the Nordea data into Ruby objects where
    # possible.
    #
    # @param [Hash] line a line from the data as a Hash
    # @return [Hash] the same line with some values converted into the
    # expected formats
    def line_postprocess(line)
      line[:quotation_time] = Nordea.parse_time(line[:quotation_time])
      line[:reserved].strip! if line[:reserved].respond_to? :strip!
      line[:rate_type] = if line[:rate_type] == "0001"
        :list
      elsif line[:rate_type] == "0002"
        :valuation
      end

      line[:euro_area] = (line[:euro_area] == "1") ? true : false

      if line[:euro_area]
        line[:euro_adoption_date] = Nordea.parse_date(line[:euro_adoption_date])
      else
        line[:euro_adoption_date] = nil
      end

      line[:currency_expiry] = (line[:currency_expiry] == "K") ? true : false

      FLOAT_KEYS.each do |key|
        str = line[key]
        float = "#{str[0,6]}.#{str[6,7]}".to_f
        line[key] = float
      end

      line
    end
  end
end