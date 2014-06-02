require 'csv'

module Ytterb
  module StockSymbol
    class Stock

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
      
      def self.builder_from_csv(stock_symbol_file, exchange)
        CSV.foreach(stock_symbol_file, :headers => true) do |obj|
          yield Stock.new(obj.to_hash.merge("Exchange" => exchange))
        end
      end

    end
  end
end # Ytterb
