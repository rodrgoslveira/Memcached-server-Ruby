require_relative '../lib/MemCached'
#Simple server running
begin
  puts "MemCachedServer-[host port]"
  intro = $stdin.gets.chomp
  host,port = intro.split(/ /)
  server = MemCacheServer.new(host,port.to_i)
  server.runServerToListen
rescue Exception => e
  puts "ERROR"
  puts ":>MESSAGE: #{e.message}"
end
