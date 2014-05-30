require 'csv'

module Ytterb

  class StockSymbol
    def initialize(options={})
      @options = {}
      options.reject {|k,v| !k }.each do |k,v|
        sym_k = k.gsub(/\s+/,"_").downcase.to_sym
        val = v.strip
        val.gsub!(/\^/,"-") if sym_k == :symbol
        @options[sym_k] = val
      end
    end

    def attributes
      return @options.keys
    end

    def method_missing(meth, *args, &block) 
      if @options.has_key?(meth)
        return @options[meth]
      else
        # don't know how to handle it
        super
      end
    end

    def to_s
      @options.to_s
    end
  end


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
