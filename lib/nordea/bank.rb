require "money"
require "nordea/exchange_rates"

module Nordea
  class Bank < Money::Bank::VariableExchange
    # TODO: Figure out what needs to be implemented for Money.gem compatibility
  end
end