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
    respone = ""
    while line = @clientSocket.gets     # Read lines from the socket
        response = "#{response}#{line.chop}\r\n"
     end
    return response
  end

end
