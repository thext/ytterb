require_relative '../../util'
require_relative '../../yql'

module Ytterb
  module StockSymbol
    class ReportBase
      def initialize
        @sml = MarketLoader.new(:with_feedback => true)
        @settings = Util::Settings.new
      end
      
      def process
        raise "not implemented"
      end
      
      def output
        raise "not implemented"
      end
    end
  end
end
