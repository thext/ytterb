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

desc "message pack test"
task :msg_pack_test do 
  require 'msgpack'
  msg = [1,2,3].to_msgpack  #=> "\x93\x01\x02\x03"
  puts msg.inspect
  demsg = MessagePack.unpack(msg)   #=> [1,2,3]
  puts demsg.inspect
end
