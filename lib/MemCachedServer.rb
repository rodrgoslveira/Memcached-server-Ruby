require 'socket'
relative_require 'MemCached'
relative_require 'MemCachedTSC'

class MemCacheServer
  attr_accessor :port, :serverSocket, :memoryCache
  def initialize(portToListen)
    @port = portToListen
    @memoryCache = MemCached.new
    @memoryCacheThreadSafe = MemCachedTSC.new
    @serverSocket = TCPServer.open(portToListen) #Socket to Listen on portToListen
  end

  def runServerToListen
      serverFlag = true
      while serverFlag
              Thread.start(self.serverSocket.accept) do |connectionSocket|
                  dataIncoming = connectionSocket.gets.chomp     # Read lines from the socket
                  message = self.requestHandler dataIncoming
                  connectionSocket.puts(message)   # Send the time to the client
                  connectionSocket.puts(Time.now.ctime)   # Send the time to the client
                  connectionSocket.close                  # Disconnect from the client
              end
      end
  end

  def requestHandler(dataIncoming)

  end

end
