path = File.expand_path(File.dirname(__FILE__))
Dir.glob(File.join(path,"**","*.rb")).each do |file|
  puts "require #{file}"
  require file
end
