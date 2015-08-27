require "nordea/bank"
require "nordea/exchange_rates"
require "nordea/version"
require "tzinfo"

# Ruby interface to the Nordea Bank exchange rate data.
module Nordea
  # The default timezone, Europe/Helsinki
  TZ = TZInfo::Timezone.get("Europe/Helsinki")

  # Parses the datetime format used in the Nordea data.
  #
  # @example
  #   Nordea.parse_time("20150101120056") #=> 2015-01-01 10:00:05 UTC
  #
  # @param [String] the datetime string (YYYYMMDDHHmmSS)
  # @return [Time] the string converted into a Time object
  def self.parse_time(datetime)
    time = Time.utc( datetime[0..3].to_i,
                     datetime[4..5].to_i,
                     datetime[6..7].to_i,
                     datetime[8..9].to_i,
                     datetime[10..11].to_i,
                     datetime[11..12].to_i )

    # Convert the local time to UTC time.
    TZ.local_to_utc(time)
    rescue
      nil
  end

  # Parses the date format used in the Nordea data.
  #
  # @param [String] the date string (YYYYMMDD)
  # @return [Date] the string converted into a Date object
  def self.parse_date(date)
    Date.new(date[0..3].to_i,
             date[4..5].to_i,
             date[6..7].to_i)
    rescue
      nil
  end
end
