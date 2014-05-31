module Ytterb
  class StockSymbol

    def initialize(options={})
      @options = {}
      options.reject {|k,v| !k }.each do |k,v|
        sym_k = k.gsub(/\s+/,"_").downcase.to_sym
        val = v.strip
        val.gsub!(/\^/,"-") if sym_k == :symbol
        @options[sym_k] = val
      end
    end

    def attributes
      return @options.keys
    end

    def method_missing(meth, *args, &block)
      if @options.has_key?(meth)
        return @options[meth]
      else
        # don't know how to handle it
        super
      end
    end

    def to_s
      @options.to_s
    end

  end # StockSymbol
end # Ytterb
