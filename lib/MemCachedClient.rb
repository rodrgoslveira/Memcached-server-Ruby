require_relative 'MemCached'
require 'socket'

class MemCacheClient
  include DataTypeModule
  attr_accessor :port, :hostname, :clientSocket
  def initialize(host,port)
    @hostname = host
    @port = port
    @clientSocket = TCPSocket.open(host,port)
    puts "Opening Client connection"
  end

  def openConnection
    @clientSocket = TCPSocket.open(self.hostname, self.port)
  end

  def shutdown
    storeMessage("exit")
    closeConnection
    puts "Closing Client connection"
  end
  #CACHE METHODS
  def get(keys)
    storeMessage("get #{keys}\r\n")
    response = []
    line = ""
    until line == "END\r\n"
      line = @clientSocket.gets
      unless line == "END\r\n"
        if line.include?"VALUE"
          response << @clientSocket.gets.chomp
        end
      end
    end
    return response unless response.length == 1
    return response[0]
  end

  def gets(keys)
    storeMessage("gets #{keys}\r\n")
    response = []
    line = ""
    until line == "END\r\n"
      line = @clientSocket.gets
      unless line == "END\r\n"
        if line.include?"VALUE"
          value,key,flags,exptime,cas_unique = line.chomp.split(/ /)
          data = @clientSocket.gets.chomp
          casTuple = CasDataType.new(cas_unique,data)
          response << casTuple
        end
      end
    end
    return response unless response.length == 1
    return response[0]
  end
  #storage METHODS
  def set(key,flags,exptime,bytes,data)
    @clientSocket.puts("set #{key} #{flags} #{exptime} #{bytes}\r\n#{data}\r\n")
    responseLine = @clientSocket.gets
    return responseLine.chomp unless responseLine.nil?
  end

  def add(key,flags,exptime,bytes,data)
    @clientSocket.puts("add #{key} #{flags} #{exptime} #{bytes}\r\n#{data}\r\n")
    responseLine = @clientSocket.gets
    return responseLine.chomp unless responseLine.nil?
  end

  def replace(key,flags,exptime,bytes,data)
    @clientSocket.puts("replace #{key} #{flags} #{exptime} #{bytes}\r\n#{data}\r\n")
    responseLine = @clientSocket.gets
    return responseLine.chomp unless responseLine.nil?
  end

  def append(key,bytes,data)
    @clientSocket.puts("append #{key} #{bytes}\r\n#{data}\r\n")
    responseLine = @clientSocket.gets
    return responseLine.chomp unless responseLine.nil?
  end

  def prepend(key,bytes,data)
    @clientSocket.puts("prepend #{key} #{bytes}\r\n#{data}\r\n")
    responseLine = @clientSocket.gets
    return responseLine.chomp unless responseLine.nil?
  end

  def cas(key,flags,exptime,bytes,cas_unique,data)
    @clientSocket.puts("cas #{key} #{flags} #{exptime} #{bytes} #{cas_unique}\r\n#{data}\r\n")
    responseLine = @clientSocket.gets
    return responseLine.chomp unless responseLine.nil?
  end

  private
  def closeConnection
    @clientSocket.close
  end

  def storeMessage(mssg)
    @clientSocket.puts(mssg)
  end
end
