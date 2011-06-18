require "money"
require "nordea/exchange_rates"

module Nordea
  # Bank implementation for use with the Money gem.
  #
  # @todo Still needs to be implemented
  class Bank < Money::Bank::VariableExchange
    # TODO: Figure out what needs to be implemented for Money.gem compatibility
  end
end