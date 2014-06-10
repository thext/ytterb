require 'msgpack'

module Ytterb
  module Util
    class DataPersistHelper
      def self.save(file, value)
        File.open(file,"w") {|f| f.write(value.to_msgpack) }
      end

      def self.load(file)
        File.open(file,"r") {|f| MessageUnpack.unpack(f.read()) }
      end

      def self.get_extension
        return ".mpack"
      end
    end
  end
end
