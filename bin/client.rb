#BASIC IMPLEMENTATION OF MEMCACHEDCLIENT SIMILAR TO TELNET
#FIRST INPUT HOST,PORT
#COMMANDS:
#:] MEANS TO EXIT
#MEMCACHED COMMANDS: get gets set add replace append prepend cas
#:>RESPONSE FROM SERVER
require 'socket'
begin
  i = 0
  puts "MemCached-[host port]"
  intro = $stdin.gets.chomp
  host, port = intro.split(/ /)
  i += 1
  @client_socket = TCPSocket.open(host, port.to_i)
  @status = "CONNECTED"
  puts "MemCached-#{@status}- input ':]' to exit"
rescue Exception => e
  error_mssg = "An error ocurred, try again\r\n"
  puts error_mssg
  retry if i < 3
  puts ":>EXCEPTION: #{e.inspect}"
  puts ":>MESSAGE: #{e.message}"
  puts ":>LOCATION:#{e.backtrace_locations}"
end
  listen = Thread.new {
    while line = @client_socket.gets
        puts ":> #{line.chomp}"
        if @status == "DISCONNECTED"
          break;
        end
    end
  }
  send = Thread.new {
    loop {
      input = $stdin.gets.chomp
      if input == ":]"
        @client_socket.puts("exit")
        @status = "DISCONNECTED"
        break;
      else
          @client_socket.puts("#{input}\r\n")
      end
      sleep(0.1)
    }
  }
  send.join
  listen.join
  @client_socket.close
  puts "MemCached-#{@status}"
