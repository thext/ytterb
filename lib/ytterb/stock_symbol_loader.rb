require 'csv'
require_relative 'stock_symbol'

module Ytterb

  class StockSymbolLoader
    def initialize(stock_symbol_file, exchange)
      @stock_symbol_file = stock_symbol_file
      @exchange = exchange
    end

    def parse
      CSV.foreach(@stock_symbol_file, :headers => true) do |obj|
        yield StockSymbol.new(obj.to_hash.merge("Exchange" => @exchange))
      end
    end
  end

end
