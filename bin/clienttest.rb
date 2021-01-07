require_relative '../lib/MemCached'
cliente = MemCacheClient.new('127.0.0.53',2000)
#  <command name> <key> <flags> <exptime> <bytes> [noreply]\r\n
puts cliente.set("key1","wr","0","MainData".bytesize,"MainData")
cas_id = cliente.gets("key1").cas
puts cliente.cas("key1","w","3600","Data-Changed".bytesize,cas_id,"Data-Changed")
puts cliente.get("key1")
puts cliente.shutdown
