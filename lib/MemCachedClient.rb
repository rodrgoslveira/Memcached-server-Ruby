require 'socket'

class MemCacheClient
  attr_accessor :port, :hostname, :clientSocket
  def initialize(host,port)
    @hostname = host
    @port = port
    @clientSocket = TCPSocket.open(host,port)
    puts "Opening Client connection"
  end

  def closeConnection
    self.clientSocket.close
  end

  def storeMessage(mssg)
    self.clientSocket.puts(mssg)
  end

  def openConnection
    self.clientSocket = TCPSocket.open(self.hostname, self.port)
  end

  def listen

    while line = self.clientSocket.gets     # Read lines from the socket
        puts line.chop
     end

  end

  #CACHE METHODS
  def get(keys)
    self.storeMessage("get #{keys}\r\n")
    infoLine = (@clientSocket.gets).chomp
    values =  (@clientSocket.gets).chomp
    return values
  end

end
