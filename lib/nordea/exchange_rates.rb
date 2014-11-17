# encoding: UTF-8
require 'net/http'
require 'uri'
require 'time'
require 'date'
require 'yaml'

module Nordea
  # Fetch and update Excahnge rates from Nordea Bank.
  #
  # Parses the custom dataformat used by Nordea into more useful Ruby types and
  # objects.
  class ExchangeRates
    # URI to the machine readable data file.
    DATA_URI = URI::HTTP.build(
      host: 'openpages.nordea.com',
      path: '/fi/lists/currency/elelctronicExchangeFI.dat'
    )

    DATA_FILE_KEYS = [
      :file_id, :record_id, :quotation_time, :rate_type,
      :currency_iso_code, :counter_currency_iso_code,
      :middle_rate_for_commercial_transactions,
      :buying_rate_for_commercial_transactions,
      :selling_rate_for_commercial_transactions,
      :buying_rate_for_cash, :selling_rate_for_cash,
      :direction_of_change, :currency_convertability,
      :euro_area, :euro_adoption_date, :currency_expiry,
      :reserved
    ]

    # Hash keys for key-value pairs that should be converted into floats.
    FLOAT_KEYS     = [
      :middle_rate_for_commercial_transactions,
      :buying_rate_for_commercial_transactions,
      :selling_rate_for_commercial_transactions,
      :buying_rate_for_cash,
      :selling_rate_for_cash
    ]

    def initialize
      @currencies = {}
      @headers    = {}
    end

    def currencies
      force_update unless @currencies.size > 0
      @currencies
    end

    def headers
      force_update unless @headers.size > 0
      @headers
    end

    # Load rates from file
    # @param [String] Path to YAML file with sames rates
    #
    def load_from_yaml(yaml_file)
      data        = ::YAML.load_file(yaml_file)
      @headers    = data[:headers]
      @currencies = data[:currencies]
    end

    # Dump rates o file
    # @param [String] Path to YAML file where need to save rates
    def dump_to_yaml(yaml_file)
      data = {
        currencies: currencies,
        headers:    headers
      }
      ::File.open(yaml_file, 'wb') { |file| file.write data.to_yaml }
    end

    private

    def force_update
      lines = fetch_data.lines.to_a
      load_headers(lines.shift)
      @currencies = load_currencies(lines)
    end

    # The batch headers
    #
    # @return [Hash] key-value pairs
    def load_headers(header_line)
      unpacked = header_line.unpack('A4A3A14A120A9')

      @headers = {
        file_id:       unpacked[0], # File ID   = VK01
        record_id:     unpacked[1], # Record ID = 000
        change_time:   unpacked[2], # Exchange rate change time
        notifications: unpacked[3], # Notifications
        reserved:      unpacked[4] # Reserved
      }
      asciify(@headers)

      @headers[:change_time] = ::Nordea.parse_time(@headers[:change_time])
      @headers[:notifications].strip! if @headers[:notifications].respond_to? :strip!
      @headers[:reserved].strip! if @headers[:reserved].respond_to? :strip!
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
    #   #                      :currency_convertability => true,
    #   #                                    :euro_area => false,
    #   #                           :euro_adoption_date => nil,
    #   #                              :currency_expiry => false,
    #   #                                     :reserved => ""
    #   # }
    #
    # @param [String] currency_lines force update
    # @return [Hash] a hash off all list currency rates and their properties
    def load_currencies(currency_lines)
      records_array(currency_lines).each_with_object({}) do |record, hash|
        hash[record[:currency_iso_code]] = record
      end
    end

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
        http.get(DATA_URI.path, 'USER_AGENT' => 'Nordea::Bank gem')
      end

      if res.code =~ /2\d\d/
        res.body
      else
        fail ServerError, 'The server did not respond in the manner in which we are accustomed to.'
      end
    end

    # The data entries as an array of hashes with minimal processing.
    #
    # @return [Array<Hash>] Array of exchange rate records
    def records_array(lines)
      lines.map { |line| collect_line(line) }.select { |rate| rate[:rate_type] == :list }
    end

    def collect_line(line)
      unpacked = line.unpack('A4A3A14A4A3A3A13A13A13A13A13AAAAx7AA42')
      hash     = {}
      DATA_FILE_KEYS.each_with_index do |key, index|
        hash[key] = unpacked[index]
      end
      line_postprocess(hash)
    end

    # Converts the string values from the Nordea data into Ruby objects where
    # possible.
    #
    # @param [Hash] line a line from the data as a Hash
    # @return [Hash] the same line with some values converted into the
    # expected formats
    def line_postprocess(line)
      # Forces the values to be ASCII strings
      asciify(line)

      line[:quotation_time] = ::Nordea.parse_time(line[:quotation_time])
      line[:reserved].strip! if line[:reserved].respond_to? :strip!
      fill_proper_rate_type(line)

      line[:euro_area] = (line[:euro_area] == '1')

      line[:euro_adoption_date] = if line[:euro_area]
                                    Nordea.parse_date(line[:euro_adoption_date])
                                  else
                                    nil
                                  end

      line[:currency_expiry]         = (line[:currency_expiry] == 'K')
      line[:currency_convertability] = (line[:currency_convertability] == 'K')
      floatify(line)

      line
    end

    def fill_proper_rate_type(line)
      line[:rate_type] = if line[:rate_type] == '0001'
                           :list
                         elsif line[:rate_type] == '0002'
                           :valuation
                         end
    end

    def floatify(line)
      FLOAT_KEYS.each do |key|
        str       = line[key]
        float     = "#{str[0, 6]}.#{str[6, 7]}".to_f
        line[key] = float
      end
    end

    def asciify(hash)
      hash.each do |key, value|
        hash[key] = value.force_encoding('ascii') if value.respond_to?(:force_encoding)
      end
    end
  end

  # The exception that's raised if the server doesn't respond correctly.
  class ServerError < StandardError
  end
end
