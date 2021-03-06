require 'rest-client'
require 'cgi'
require 'date'

require_relative 'exceptions'
require_relative 'response'

module Ytterb
  module Yql
    class Client
      def initialize
        @endpoint = "http://query.yahooapis.com/v1/public/yql"
      end

      def get_yql_endpoint
        @endpoint
      end

      def run_select_query(query)
        RestClient.get("#{get_yql_endpoint}?q=#{CGI::escape(query)}&format=json&env=store://datatables.org/alltableswithkeys") do |response, request, result|
          raise ClientYqlError, "Failed performing YQLQuery\n" << 
                                    "Request: #{request.inspect}\n" <<
                                    "Response #{response.inspect}" unless response.code == 200
          return Response.new(response).lines
        end
      end

      def get_symbol_historical(my_symbol, start_date = nil, end_date = nil)
        requested_end = Date.parse(end_date) if end_date
        requested_end = Date.today unless requested_end

        requested_start = Date.parse(start_date) if start_date
        requested_start = requested_end - 30 unless requested_start
        run_select_query("select * from yahoo.finance.historicaldata" <<
                          " where symbol in (\"#{my_symbol}\")" <<
                          " and startDate='#{requested_start}'" <<
                          " and endDate='#{requested_end}'")
      end

    end
  end
end
