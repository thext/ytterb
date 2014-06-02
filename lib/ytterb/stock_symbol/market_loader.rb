require_relative '../util'
require_relative 'stock'

module Ytterb
  module StockSymbol
    class MarketLoader
      def initialize
        @stock_symbols = []
        path = Util::Settings.new.get_raw_symbol_list_data_dir
        Dir.entries(path).select {|f| !File.directory?(f) and /companylist_[a-zA-Z]+\.csv/ =~ f }.each do |file_to_process|
          market = /companylist_(?<market>[a-zA-Z]+)\.csv/.match(file_to_process)[:market]
          Stock.builder_from_csv(File.join(path,file_to_process),market) do |stock_symbol|
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
end

