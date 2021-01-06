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
  host,port = intro.split(/ /)
  i += 1
  @clientSocket = TCPSocket.open(host,port.to_i)
  @status = "CONNECTED"
  puts "MemCached-#{@status}- input ':]' to exit"
rescue Exception => e
  errorMssg = "An error ocurred, try again\r\n"
  puts errorMssg
  retry if i < 3
  puts ":>EXCEPTION: #{e.inspect}"
  puts ":>MESSAGE: #{e.message}"
  puts ":>LOCATION:#{e.backtrace_locations}"
end
  listen = Thread.new {
    while line = @clientSocket.gets
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
        @clientSocket.puts("exit")
        @status = "DISCONNECTED"
        break;
      else
          @clientSocket.puts("#{input}\r\n")
      end
      sleep(0.1)
    }
  }
  send.join
  listen.join
  @clientSocket.close
  puts "MemCached-#{@status}"
