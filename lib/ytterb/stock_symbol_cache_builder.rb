require 'fileutils'
require_relative 'stock_symbol_loader'

module Ytterb

  class StockSymbolCacheBuilder
    def initialize
      @sml = StockMarketLoader.new
      @symbol_mappings = {}
      cache_path = File.join(File.expand_path(File.dirname(__FILE__)),"cached_symbol_data")
      @sml.stock_symbols.each do |stock|
		current_symbol = stock.symbol
		split_for_storage = current_symbol.split('')
		split_for_storage[-1]+='.json'
		destination_storage_file = File.join(cache_path,split_for_storage)
		FileUtils.mkdir_p(File.dirname(destination_storage_file))
		unless File.file?(destination_storage_file)
		  FileUtils.touch(destination_storage_file)
		  puts "touching #{current_symbol} => #{destination_storage_file}"
		end
		@symbol_mappings[current_symbol] = destination_storage_file
      end
    end
  end

end
