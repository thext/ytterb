require_relative '../util'
require_relative 'stock'

module Ytterb
  module StockSymbol
    class MarketLoader
      def initialize(options={})
        @stock_symbols = []
        path = Util::Settings.new.get_raw_symbol_list_data_dir
        i=1
        Dir.entries(path).select {|f| !File.directory?(f) and /companylist_[a-zA-Z]+\.csv/ =~ f }.each do |file_to_process|
          market = /companylist_(?<market>[a-zA-Z]+)\.csv/.match(file_to_process)[:market]
          Stock.builder_from_csv(File.join(path,file_to_process),market) do |stock_symbol|
            if options[:with_feedback]
              print "."
              print "#{i}\n" if (i%80==0)
              i+=1
            end
            @stock_symbols << stock_symbol
          end
        end
        print "\n" if options[:with_feedback]
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

