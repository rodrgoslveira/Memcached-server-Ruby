require_relative 'memcached'
require 'socket'

class MemCacheClient
  include DataTypeModule

  attr_accessor :port, :hostname, :client_socket

  def initialize(host,port)
    @hostname = host
    @port = port
    @client_socket = TCPSocket.open(host, port)
    puts "Opening Client connection"
  end

  def open_connection
    @client_socket = TCPSocket.open(self.hostname, self.port)
  end

  def shutdown
    store_message("exit")
    close_connection
    puts "Closing Client connection"
  end
  #CACHE METHODS
  def get(keys)
    store_message("get #{keys}\r\n")
    response = []
    line = ""
    until line == "END\r\n"
      line = @client_socket.gets
      unless line == "END\r\n"
        if line.include?"VALUE"
          response << @client_socket.gets.chomp
        end
      end
    end
    return response unless response.length == 1
    return response[0]
  end

  def gets(keys)
    store_message("gets #{keys}\r\n")
    response = []
    line = ""
    until line == "END\r\n"
      line = @client_socket.gets
      unless line == "END\r\n"
        if line.include?"VALUE"
          value, key, flags, exptime, cas_unique = line.chomp.split(/ /)
          data = @client_socket.gets.chomp
          cas_tuple = CasDataType.new(cas_unique, data)
          response << cas_tuple
        end
      end
    end
    return response unless response.length == 1
    return response[0]
  end
  #storage METHODS
  def set(key, flags, exptime, bytes, data)
    @client_socket.puts("set #{key} #{flags} #{exptime} #{bytes}\r\n#{data}\r\n")
    response_line = @client_socket.gets
    response_line.chomp unless response_line.nil?
  end

  def add(key, flags, exptime, bytes, data)
    @client_socket.puts("add #{key} #{flags} #{exptime} #{bytes}\r\n#{data}\r\n")
    response_line = @client_socket.gets
    response_line.chomp unless response_line.nil?
  end

  def replace(key, flags, exptime, bytes, data)
    @client_socket.puts("replace #{key} #{flags} #{exptime} #{bytes}\r\n#{data}\r\n")
    response_line = @client_socket.gets
    response_line.chomp unless response_line.nil?
  end

  def append(key, bytes, data)
    @client_socket.puts("append #{key} #{bytes}\r\n#{data}\r\n")
    response_line = @client_socket.gets
    response_line.chomp unless response_line.nil?
  end

  def prepend(key, bytes, data)
    @client_socket.puts("prepend #{key} #{bytes}\r\n#{data}\r\n")
    response_line = @client_socket.gets
    response_line.chomp unless response_line.nil?
  end

  def cas(key, flags, exptime, bytes, cas_unique, data)
    @client_socket.puts("cas #{key} #{flags} #{exptime} #{bytes} #{cas_unique}\r\n#{data}\r\n")
    response_line = @client_socket.gets
    response_line.chomp unless response_line.nil?
  end

  private
  
  def close_connection
    @client_socket.close
  end

  def store_message(mssg)
    @client_socket.puts(mssg)
  end
end
