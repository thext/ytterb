require 'date'

require_relative '../../util'
require_relative '../../yql'
require_relative 'report_base'


module Ytterb
  module StockSymbol
    class Freshness < ReportBase
      def process
        @freshness = {}
        @sml.stock_symbols.each do |smbl|
          latest = smbl.history.keys.collect {|x| Date.parse(x)}.sort.last.to_s
          @freshness[latest] ||= []
          @freshness[latest] << smbl
        end
      end
      
      def output
        output = "Freshness report\n" <<
            "----------------\n"
        @freshness.keys.sort.reverse.each {|k| output += "'#{k}' => #{@freshness[k].size} \n" }
        output
      end
    end
  end
end
