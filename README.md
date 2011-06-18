The Nordea Gem
==============

     _________________________________ 
    < Exchange rates from Nordea Bank >
     --------------------------------- 
            \   ^__^
             \  (€€)\_______
                (__)\       )\/\
                    ||----w |
                    ||     ||


Installation
------------

Just like any other gem:

    gem install nordea


Usage
-----

Something, something, something, darkside.

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


About the data and data source
------------------------------

Nordea quotes exchange rates on national banking days at least three times a day:

* in the morning at 8.00,
* at noon at 12.15 and
* in the afternoon at 16.15 (approximate times).

Useful links:

* [More information about Nordea exchange rates](http://j.mp/Nordea_exchange_rates)
* [More information about the data format](http://j.mp/Rates_for_electronic_processing) [PDF]

### Disclaimer

* This is **not** an *official* gem from Nordea.
* I have **no affiliation** to any entity connected to Nordea Bank.
* I **do not** have any control over the exchange rate data provided, and you use
this gem entirely at **your own risk**.

License
-------

MIT License. Copyright 2011 Matias Korhonen.

See the LICENSE file for more details.