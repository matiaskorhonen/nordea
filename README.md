The Nordea Gem
==============

[![Build Status](https://travis-ci.org/matiaskorhonen/nordea.png?branch=master)](https://travis-ci.org/matiaskorhonen/nordea) [![Code Climate](https://codeclimate.com/github/k33l0r/nordea.png)](https://codeclimate.com/github/k33l0r/nordea) [![Gem Version](https://badge.fury.io/rb/nordea.png)](http://badge.fury.io/rb/nordea)

Exchange rates from Nordea Bank.

Installation
------------

Just like any other gem:

    gem install nordea


Usage
-----

### With the Money gem

The Money gem integration works in a similar way to the [eu\_central\_bank](https://github.com/RubyMoney/eu_central_bank) library, mostly because I referenced that gem while building this one. A couple of the methods in the Nordea::Bank class are pretty much identical to those in the eu\_central\_bank gem.

    nordea_bank = Nordea::Bank.new
    Money.default_bank =  nordea_bank

    # Exchange 100 EUR to USD
    nordea_bank.exchange(100, "EUR", "USD")

    # Exchange 100 USD to South African rands
    Money.us_dollar(100).exchange_to("ZAR")

    # Exchange 100 Canadian dollars to US dollars
    nordea_bank.exchange_with(Money.new(100, "CAD"), "USD")

    # Update the forex rates
    nordea_bank.update_rates

### Without the Money gem

    exchange_rates = Nordea::ExchangeRates.new

    exchange_rates.currencies
      #=> returns a hash of currencies

    exchange_rates.currencies(true)
      #=> returns a hash of currencies, but forces a data update

    exchange_rates.headers
      #=> returns a hash of the data headers from Nordea

For more information, read the [documentation](http://rubydoc.info/gems/nordea).


Ruby compatibility
------------------

The gem should work with MRI Ruby (only Ruby 2.2 and 2.1 are actively targetted) and jRuby (in 1.9 mode).


About the data and data source
------------------------------

Nordea quotes exchange rates on national banking days at least three times a day:

* in the morning at 8.00,
* at noon at 12.15 and
* in the afternoon at 16.15 (approximate times).

### Useful links:

* [More information about Nordea exchange rates](http://j.mp/Nordea_exchange_rates)
* [More information about the data format](http://j.mp/Rates_for_electronic_processing) [PDF]

### Disclaimer

* This is **not** an *official* gem from Nordea.
* I have **no affiliation** to any entity connected to Nordea Bank.
* I **do not** have any control over the exchange rate data provided, and you use
this gem entirely at **your own risk**.

License
-------

MIT License. Copyright 2011-2013 Matias Korhonen.

See the LICENSE file for more details.
