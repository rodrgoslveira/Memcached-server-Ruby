require_relative '../lib/memCachedModules'

cliente = MemCacheClient.new('localhost',2000)

#  <command name> <key> <flags> <exptime> <bytes> [noreply]\r\n

        cliente.storeMessage("set key1 1 2020 8 1\r\ndataaaaaaaaaaaaaaaaaaaaaaaaaaaaa\r\n")
        cliente.listen
        cliente.closeConnection
        cliente.openConnection
        cliente.storeMessage("get key1\r\n")
        cliente.listen
        cliente.closeConnection
