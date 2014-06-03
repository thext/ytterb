require 'json'

require_relative 'exceptions'

module Ytterb
  module Yql
    class Response
      def initialize(raw)
        begin
          @response = JSON.parse(raw)
        rescue
          raise InvalidYqlResponse, "failed parsing yql response"
        end
        build_response_lines
      end
      
      def validate_response_line(line)
        raise InvalidYqlResponse, "response line needs to be a hash. found a #{line.class}" unless line.kind_of?(Hash)
        line.select! do |k,v|
          ["Symbol", "Date", "Open", "High", "Low", "Close", "Volume", "Adj_Close"].include?(k)
        end
        line
      end
      
      def build_response_lines
        @response_lines = []
        return unless @response.has_key?("query")
        return unless @response["query"].has_key?("count")
        return unless @response["query"]["count"].to_i > 0
        return unless @response["query"].has_key?("results")
        return unless @response["query"]["results"].has_key?("quote")
        if @response["query"]["results"]["quote"].kind_of?(Hash)
          @response_lines << validate_response_line(@response["query"]["results"]["quote"])
        elsif @response["query"]["results"]["quote"].kind_of?(Array)
          @response["query"]["results"]["quote"].each do |line|
            @response_lines << validate_response_line(line)
          end
        else
          raise InvalidYqlResponse, "response/query/results/quote needs to be an Array or a Hash. Found a #{@response["query"]["results"]["quote"].class}"
        end
        @response_lines.each do |line|
          puts "  #{line}"
        end
      end
      
      def lines
        @response_lines
      end
      
    end
  end
end
