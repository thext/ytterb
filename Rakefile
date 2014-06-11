# encoding: utf-8

require 'rubygems'

begin
  require 'bundler'
rescue LoadError => e
  warn e.message
  warn "Run `gem install bundler` to install Bundler."
  exit -1
end

begin
  Bundler.setup(:development)
rescue Bundler::BundlerError => e
  warn e.message
  warn "Run `bundle install` to install missing gems."
  exit e.status_code
end

require 'rake'

require 'rubygems/tasks'
Gem::Tasks.new

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  rdoc.title = "ytterb"
end
task :doc => :rdoc

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task :test    => :spec
task :default => :spec

desc "builds the stock cache"
task :build_stock_cache do 
  require_relative 'lib/ytterb'
  Ytterb::StockSymbol::CacheBuilder.new
end

desc "generate stock data freshness report"
task :generate_freshness_report do
  require_relative 'lib/ytterb'
  Ytterb::StockSymbol::Report.new(:type => :freshness).generate
end

desc "test load single stock"
task :load_single_stock do
  require_relative 'lib/ytterb'
  test_stock = Ytterb::StockSymbol::Stock.new("symbol"=>"FF")
  puts "Test loading single stock"
  puts test_stock.history.inspect
  test_stock.fetch_history
  test_stock.save
end

