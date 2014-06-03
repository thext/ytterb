require 'thread'
require 'date'

require_relative '../util'
require_relative '../yql'
require_relative 'market_loader'

module Ytterb
  module StockSymbol
    class CacheBuilder

      def initialize
        @sml = MarketLoader.new      
        @local_settings = Util::Settings.new

        # build the queue used when syncing
        build_stock_sync_queue

        # run the processor that fetches and persists stock info
        stock_processor_run

        @local_settings.save
      end

      def build_stock_sync_queue
        @stock_sync_queue = Queue.new
        @sml.stock_symbols.shuffle.each do |stock|
          @stock_sync_queue << stock
        end
      end

      def stock_processor_run
        while true
          curr = @stock_sync_queue.pop(true) rescue nil
          break unless curr # queue is empty
          puts "Processing Symbol: #{curr}"
          curr.fetch_history
        end
      end

    end # CacheBuilder
  end 
end
