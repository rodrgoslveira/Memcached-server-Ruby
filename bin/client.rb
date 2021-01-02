require_relative '../lib/memCachedModules'
@counter = 0
@m = Mutex.new
def incrCounter()
  @m.synchronize do
    @counter += 1
  end
end
cliente = MemCacheClient.new('localhost',2000)

#  <command name> <key> <flags> <exptime> <bytes> [noreply]\r\n

        cliente.storeMessage("set key1 1 3600 1 \r\n0\r\n")
        cliente.listen
        cliente.closeConnection
        threads = []
        #-------------------------------------------------------------------------------------
        100.times do
          threads <<  Thread.new {
              clienteI = MemCacheClient.new('localhost',2000)
              incrCounter()
              clienteI.openConnection
              clienteI.storeMessage("replace key1 1 3600 30 \r\n#{@counter}\r\n")
              clienteI.closeConnection
            }
       end
       puts "threads lenght = #{threads.length}"
       threads.each(&:join)
        cliente.openConnection
        cliente.storeMessage("get key1\r\n")
        cliente.listen
        cliente.closeConnection
