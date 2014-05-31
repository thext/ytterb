require_relative 'data_persist_helper'

module Ytterb
  class Settings
    def initialize
      @options = {
        :settings_dir => "local_settings",
        :settings_file => File.join("settings",DataPersistHelper.get_extension()),
        :cached_symbol_data_dir => "cached_symbol_data"
      }.freeze
      @local_path = File.expand_path(File.dirname(__FILE__))
      load
    end
    
    def set_defaults_if_uninitialized
      # defaults to be used if not defined
      @local_settings ||= {}
      @local_settings[:sync_from] ||= (Date.today-365).to_s
      @local_settings[:sync_increment] ||= 120
      @local_settings[:api_calls_per_hour] ||= 1900
    end
    
    def create_full_path_and_file(full_path) 
      FileUtils.mkdir_p(File.dirname(full_path))
      unless File.file?(full_path)
        FileUtils.touch(full_path)
      end
    end
    
    def full_path_settings_file
      File.join(@local_path,@options[:settings_dir],@options[:settings_file])
    end
    
    def get_symbol_store_file(symbol, build_path_and_file = true)
      split_for_storage = symbol.split('')
      split_for_storage[-1] += DataPersistHelper.get_extension()
      full_path = File.join(@local_path,@options[:cached_symbol_data_dir],split_for_storage)
      create_full_path_and_file(full_path)  if build_path_and_file == true
      full_path
    end
    
    def [](key)
      @local_settings[key]
    end
    
    def []=(key, value)
      @local_settings[key] = value
    end
    
    def load
      @local_settings = DataPersistHelper.load(full_path_settings_file())
    rescue
    ensure
      set_defaults_if_uninitialized
    end

    def save
      create_full_path_and_file(full_path_settings_file())
      DataPersistHelper.load(full_path_settings_file(), @local_settings)
    end
  end
end
