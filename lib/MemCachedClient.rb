require 'socket'

class MemCacheClient
  attr_accessor :port, :hostname, :clientSocket
  def initialize(host,port)
    @hostname = 'localhost'
    @port = 2000
    @clientSocket = TCPSocket.open(self.hostname, self.port)
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
    puts "\n--------------------------------------SERVER MESSAGE\n"
    while line = self.clientSocket.gets     # Read lines from the socket
        puts line.chop
     end
    puts "\n----------------------------------------------------\n"
  end
end