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
        initial_queue_size = @stock_sync_queue.length
        prev_done = 0
        puts "Initial queue size is #{initial_queue_size}"
        while true
          begin
            curr = @stock_sync_queue.pop(true) rescue nil
            break unless curr # queue is empty
            sleep(3600.0/@local_settings[:api_calls_per_hour])
            curr.fetch_history
            curr_done = (initial_queue_size - @stock_sync_queue.length) * 100 / initial_queue_size
            if curr_done > prev_done
              puts "#{curr_done} %"
              prev_done = curr_done
            else
              print "#{curr.symbol}."
            end
          rescue StandardError => e
            puts "#{e.message} : #{e.backtrace.join("|")}"
          end
        end
      end

    end # CacheBuilder
  end 
end
