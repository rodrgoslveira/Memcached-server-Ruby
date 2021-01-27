require_relative '../lib/memcached'
#Simple server running
begin
  puts "MemCachedServer-[host port]"
  intro = $stdin.gets.chomp
  host, port = intro.split(/ /)
  server = MemCacheServer.new(host, port.to_i)
  server.run_server_to_listen
rescue Exception => e
  puts "ERROR"
  puts ":>MESSAGE: #{e.message}"
end
