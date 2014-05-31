require_relative 'stock_symbol_loader'

module Ytterb

  class StockMarketLoader
    def initialize
      @stock_symbols = []
      path = File.join(File.expand_path(File.dirname(__FILE__)),"raw_symbol_data")
      Dir.entries(path).select {|f| !File.directory?(f) and /companylist_[a-zA-Z]+\.csv/ =~ f }.each do |file_to_process|
        market = /companylist_(?<market>[a-zA-Z]+)\.csv/.match(file_to_process)[:market]
        StockSymbolLoader.new(File.join(path,file_to_process),market).parse do |stock_symbol|
          @stock_symbols << stock_symbol
        end
      end
    end

    def industries
      return @industries if @industries
      @raw_industries = {}
      @stock_symbols.each do |stock_symbol|
        @raw_industries[stock_symbol.industry] = 1
      end
      @industries = @raw_industries.keys
    end

    def sectors
      return @sectors if @sectors
      @raw_sectors = {}
      @stock_symbols.each do |stock_symbol|
        @raw_sectors[stock_symbol.sector] = 1
      end
      @sectors = @raw_sectors.keys
    end

    def stock_symbols
      @stock_symbols
    end
  end

end
  
