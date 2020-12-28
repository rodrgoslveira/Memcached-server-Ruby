require_relative '../lib/memCachedModules'

server = MemCacheServer.new(2000)

server.runServerToListen
