require 'yaml'

module Ytterb
  module Util
    class DataPersistHelper
      def self.save(file, value)
        File.open(file,"w") {|f| f.write(YAML.dump(value)) }
      end

      def self.load(file)
        File.open(file,"r") {|f| YAML.load(f.read()) }
      end

      def self.get_extension
        return ".yaml"
      end
    end
  end
end
