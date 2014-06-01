require 'fileutils'
require 'thread'
require 'date'
require_relative 'data_persist_helper'
require_relative 'settings'
require_relative 'stock_market_loader'
require_relative 'yql_client'

module Ytterb

  class StockSymbolCacheBuilder

    def initialize
      @yql = YQLClient.new
      @sml = StockMarketLoader.new      
      @local_settings = Settings.new

      # build the queue used when syncing
      build_stock_sync_queue

      # run the processor that fetches and persists stock info
      stock_processor_run

      @local_settings.save
    end

    def build_stock_sync_queue
      @stock_sync_queue = Queue.new
      @sml.stock_symbols.shuffle.each do |stock|
        @stock_sync_queue << stock.symbol
      end
    end

    def stock_processor_run
      while true
        begin
          curr = @stock_sync_queue.pop(true) rescue nil
          break unless curr # queue is empty
          sleep(3600.0/@local_settings[:api_calls_per_hour])
          puts "#{@stock_sync_queue.length} symbols in the queue"
          puts "Processing Symbol: #{curr}"
          curr_file = @local_settings.get_symbol_store_file(curr)
          curr_stock_info = DataPersistHelper.load(curr_file) rescue nil
          curr_stock_info ||= {}
          curr_stock_info[:sync_to] ||= @local_settings[:sync_from]
          date_start = Date.parse(curr_stock_info[:sync_to])
          if (date_start < Date.today)
            date_end = date_start + @local_settings[:sync_increment]
            date_end = Date.today if date_end > Date.today
            result = @yql.get_symbol_historical(curr,date_start.to_s, date_end.to_s)
            max_end_date = Date.parse(curr_stock_info[:sync_to])
            symbol_updated = false
            if result and result.has_key?("quote") and result["quote"].kind_of?(Array)
              # TODO: need to pull all this logic into the yql client
              # TODO: this needs some tests!
              result["quote"].each do |item|
                if item["Date"]
                  curr_stock_info[:data]||={}
                  curr_stock_info[:data][item["Date"]] = item
                  if Date.parse(item["Date"]) > max_end_date
                    max_end_date = Date.parse(item["Date"])
                    curr_stock_info[:sync_to] = max_end_date.to_s
                    symbol_updated = true
                  end
                end
              end
              @stock_sync_queue << curr if symbol_updated
              puts curr_stock_info[:sync_to]
              DataPersistHelper.save(curr_file,curr_stock_info)
            else
              puts "Debug result: #{result}"
            end
          end
        rescue StandardError => e
          puts "error in stock processor run: #{e.message} : #{e.backtrace.join(" | ")}"
        end
      end
    end


  end # StockSymbolCacheBuilder
end
