require_relative '../util'
require_relative '../yql'
require_relative '_req'

module Ytterb
  module StockSymbol
    class Report
    
      def initialize(options={})
        if options[:type]
          case options[:type]
          when :freshness
            @report = Freshness.new
          else
            raise "unknown report type #{options[:type]}"
          end
        end
      end
      
      def generate
        @report.process
        puts @report.output
      end
    end
  end
end
