require 'csv'

require_relative '../util'
require_relative '../yql'

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
        # not interested in variable data which was captured in the stock list
        @options.reject! {|k,v| [:lastsale, :marketcap, :adr_tso].include?(k) }
        load
      end

      def self.builder_from_csv(stock_symbol_file, exchange)
        CSV.foreach(stock_symbol_file, :headers => true) do |obj|
          yield Stock.new(obj.to_hash.merge("Exchange" => exchange))
        end
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
      
      ## load/save operations
      def self.get_settings
        @settings ||= Util::Settings.new
      end
      
      def load
        symbol_history_file = self.class.get_settings.get_symbol_store_file(self.symbol)
        @history = Util::DataPersistHelper.load(symbol_history_file) rescue nil
      end
      
      def save
        return unless @history
        symbol_history_file = self.class.get_settings.get_symbol_store_file(self.symbol)
        Util::DataPersistHelper.save(symbol_history_file,@history)
      end
            
      # history via yql operation
      def self.get_yql_client
        @yql_client ||= Yql::Client.new
      end
      
      def fetch_history(start_date = nil, end_date = nil)
        @history||={}
        start_date = @history.keys.collect {|x| Date.parse(x)}.sort.last
        start_date = start_date.to_s if start_date
        start_date ||= self.class.get_settings[:sync_from]
    
        self.class.get_yql_client.get_symbol_historical(@options[:symbol], start_date, end_date).each do |line|
          @history[line["Date"]] = line
        end
        save
      end
      
      def history
        return {} unless @history
        @history
      end
      
    end
  end
end # Ytterb
