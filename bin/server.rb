require_relative '../lib/MemCached'
#Simple server running
begin
  server = MemCacheServer.new('127.0.0.53',2000)
  server.runServerToListen
rescue Exception => e
  puts "ERROR"
  puts ":>MESSAGE: #{e.message}"
end
