require 'socket'
require_relative 'memcached'

class MemCacheServer
  include DataTypeModule

  attr_accessor :port, :server_socket, :memory_cache
  
  def initialize(host, port)
    @port = port
    @memory_cache = Cache.new
    @host = host
    @server_socket = TCPServer.new(host, port) #Socket to listen on port
    puts "opening Server Socket at Port #{self.port}"
  end

  def run_server_to_listen
    puts "Server ready to listen"
    loop {
      Thread.start(self.server_socket.accept) do |connection_socket|
        begin
          puts ":>Openning connection with: #{connection_socket.to_s}"
          keep_listening = true
          while keep_listening
              data_incoming = connection_socket.gets # Read line from the socket
              keep_listening = request_handler(data_incoming.chomp, connection_socket) unless data_incoming.nil?
          end
          puts ":>Closing connection with: #{connection_socket.to_s}"
          connection_socket.close # Disconnect from the client
        rescue Exception => e
          error_mssg = "SERVER_ERROR an error ocurred, closing connection\r\n"
          connection_socket.puts(error_mssg)
          connection_socket.close # Disconnect from the client
          puts ":>EXCEPTION: #{e.inspect}"
          puts ":>MESSAGE: #{e.message}"
          puts ":>LOCATION:#{e.backtrace_locations}"
        end
      end
    }
  end

private

  def request_handler(data_incoming, client)
    command = data_incoming.split(/ /)
    check_reply = true
    response_flag = true
    handler_response = true
    case command[0]
    when "get", "gets"
      mssg_to_transmit = try_retrival(data_incoming, command[0])
      check_reply = false
    when "set", "add", "replace", "append", "prepend", "cas"
      response_flag, mssg_to_transmit = try_storage(data_incoming, client, command[0])
    when "exit"
      handler_response = false
      response_flag = false
    else
      mssg_to_transmit = "CLIENT_ERROR nonexistent command name\r\n"
      check_reply = false
    end
    try_transmit(mssg_to_transmit, check_reply, response_flag, client)
    handler_response
  end

  def try_retrival(data_incoming, command)
    lines = data_incoming.split(/ /, 2)
    keys = lines[1].split(/ /)
    response_from_cache = command == "get" ? @memory_cache.get(keys) : @memory_cache.gets(keys)
  end

  def try_storage(command_line, client, command)
    response = Array.new(2,true)
      case command
      when "set","add","replace"
        command, key, flags, exptime, bytes, noreply = command_line.split(/ /)
        data_block = client.read(bytes.to_i + 2).chomp # +2 means read \r\n
        response[1] =
          if command == "set"
            @memory_cache.set(key, flags, exptime, data_block, bytes)
          elsif command == "add"
            @memory_cache.add(key, flags, exptime, data_block, bytes)
          else
            @memory_cache.replace(key, flags, exptime, data_block, bytes)
          end
      when "append","prepend"
        command, key, bytes = command_line.split(/ /)
        data_block = client.read(bytes.to_i + 2).chomp
        response[1] = command == "append" ? @memory_cache.append(key, data_block, bytes) : @memory_cache.prepend(key, data_block, bytes)
      when "cas"
        command, key, flags, exptime, bytes, cas, noreply = command_line.split(/ /)
        data_block = client.read(bytes.to_i + 2).chomp
        response[1] = self.memory_cache.cas(key, flags, exptime, bytes, cas.to_i, data_block)
      end
    #noreply evaluation
    if !(noreply.eql? "0")
      response[0] = false unless noreply.nil?
    end
      return response
  end

  def try_transmit(mssg, check_reply, response_flag, client)
    client.puts(mssg) unless ( (check_reply && !response_flag) )
    if response_flag
        puts ":>Sending to #{client.to_s}:\n #{mssg}"
    end
  end
end
