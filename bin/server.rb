require_relative '../lib/memCachedModules'
begin
  server = MemCacheServer.new(2000)
  server.runServerToListen
rescue Exception => e
  puts "ERROR"
  puts ":>MESSAGE: #{e.message}"
end
