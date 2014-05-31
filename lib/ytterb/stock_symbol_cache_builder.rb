require 'fileutils'
require 'thread'
require 'date'
require_relative 'data_persist_helper'
require_relative 'stock_market_loader'
require_relative 'yql_client'

module Ytterb

  class StockSymbolCacheBuilder
  
    def initialize
      @yql = YQLClient.new
      @sml = StockMarketLoader.new
      @local_path = File.expand_path(File.dirname(__FILE__))
      build_local_symbol_files
      load_build_local_settings_file
      @local_settings ||= {}
      
      # defaults to be used if not defined
      @local_settings[:sync_from] ||= (Date.today-365).to_s
      @local_settings[:sync_increment] ||= 120
      @local_settings[:api_calls_per_hour] ||= 1900
      
      # build the queue used when syncing
      build_stock_sync_queue
      
      # run the processor that fetches and persists stock info
      stock_processor_run
      
      save_local_settings_file
    end
    
    def build_local_symbol_files
      @symbol_mappings = {}
      cache_path = File.join(@local_path, "cached_symbol_data")
      @sml.stock_symbols.each do |stock|
        current_symbol = stock.symbol
        split_for_storage = current_symbol.split('')
        split_for_storage[-1] += DataPersistHelper.get_extension()
        destination_storage_file = File.join(cache_path,split_for_storage)
        FileUtils.mkdir_p(File.dirname(destination_storage_file))
        unless File.file?(destination_storage_file)
          FileUtils.touch(destination_storage_file)
          puts "touching #{current_symbol} => #{destination_storage_file}"
        end
        @symbol_mappings[current_symbol] = destination_storage_file
      end
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
          curr_file = @symbol_mappings[curr]
          curr_stock_info = DataPersistHelper.load(curr_file) rescue nil
          curr_stock_info ||= {}
          curr_stock_info[:sync_to] ||= @local_settings[:sync_from]
          date_start = Date.parse(curr_stock_info[:sync_to])
          if (date_start < Date.today)
            date_end = date_start + @local_settings[:sync_increment]
            date_end = Date.today if date_end > Date.today
            result = @yql.get_symbol_historical(curr,date_start.to_s, date_end.to_s)
            curr_stock_info[:sync_to] = date_end.to_s
            if result and result.has_key?("quote")
              result["quote"].each do |item|
                curr_stock_info[:data]||={}
                curr_stock_info[:data][item["Date"]] = item
              end
              @stock_sync_queue << curr
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
    
    def load_build_local_settings_file
      local_settings_file = File.join(@local_path, "local_settings", "settings.yaml")
      @local_settings = DataPersistHelper.load(local_settings_file)
    rescue StandardError => e
      puts "failed to load local settings file: #{e.message}"
    end
    
    def save_local_settings_file
      local_settings_file = File.join(@local_path, "local_settings", "settings.yaml")
      DataPersistHelper.save(local_settings_file, @local_settings)
    end
  end # StockSymbolCacheBuilder
end
