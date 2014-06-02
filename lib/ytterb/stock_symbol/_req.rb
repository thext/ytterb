path = File.expand_path(File.dirname(__FILE__))
Dir.glob(File.join(path,"**","*.rb")).each {|f| require f }
