require 'socket'
require_relative 'MemCached'


class MemCacheServer
  include DataTypeModule
  attr_accessor :port, :serverSocket, :memoryCache
  def initialize(hostServer,portToListen)
    @port = portToListen
    @memoryCache = Cache.new
    @host = hostServer
    @serverSocket = TCPServer.new(hostServer,portToListen) #Socket to Listen on portToListen
    puts "opening Server Socket at Port #{self.port}"
  end

  def runServerToListen
    puts "Server ready to listen"
    loop {
      Thread.start(self.serverSocket.accept) do |connectionSocket|
        begin
          puts ":>Openning connection with: #{connectionSocket.to_s} "
          keepListening = true
          while keepListening
              dataIncoming = connectionSocket.gets # Read line from the socket
              keepListening = requestHandler(dataIncoming.chomp,connectionSocket) unless dataIncoming.nil?
          end
          puts ":>Closing connection with: #{connectionSocket.to_s} "
          connectionSocket.close # Disconnect from the client
        rescue Exception => e
          errorMssg = "SERVER_ERROR an error ocurred, closing connection\r\n"
          connectionSocket.puts(errorMssg)         # Send the response to the client
          connectionSocket.close                  # Disconnect from the client
          puts ":>EXCEPTION: #{e.inspect}"
          puts ":>MESSAGE: #{e.message}"
          puts ":>LOCATION:#{e.backtrace_locations}"
        end
      end
    }
  end

private

  def requestHandler(dataIncoming,client)
    command = dataIncoming.split(/ /)
    message = ""
    checkReply = true
    responseFlag = true
    result = true
    case command[0]
    when "get"
      message = retrievalHandler(dataIncoming)
      checkReply = false
    when "gets"
      message = retrievalHandler(dataIncoming)
      checkReply = false
    when "set"
      responseFlag,message = storageHandler(dataIncoming,client,command[0])
    when "add"
      responseFlag,message = storageHandler(dataIncoming,client,command[0])
    when "replace"
      responseFlag,message = storageHandler(dataIncoming,client,command[0])
    when "append"
      responseFlag,message = storageHandler(dataIncoming,client,command[0])
    when "prepend"
      responseFlag,message = storageHandler(dataIncoming,client,command[0])
    when "cas"
      responseFlag,message = storageHandler(dataIncoming,client,command[0])
    when "exit"
      result = false
      responseFlag = false
    else
      message = "CLIENT_ERROR nonexistent command name\r\n"
      checkReply = false
    end
    client.puts(message) unless ( (checkReply && !responseFlag) )
    if responseFlag
        puts ":>Sending to #{client.to_s}:\n #{message}"
    end
    return result
  end
  # Each item sent by the server looks like this:
  # VALUE <key> <flags> <bytes> [<cas unique>]\r\n
  # <data block>\r\n
  # After all the items have been transmitted, the server sends the string
  #"END\r\n"
  def retrievalHandler(requestIncoming)
    command = requestIncoming.split(/ /,2)
    keys = command[1].split(/ /)
    result = []
    message = ""
    case command[0]
    when "get"
      result = self.memoryCache.get(keys)
      result.each{ |e|
         message = "#{message}VALUE #{e.key} #{e.flags} #{e.bytes}\r\n#{e.data}\r\n"
      }
      finalString = "#{message}END\r\n"
    when "gets"
      result = self.memoryCache.gets(keys)
      result.each{ |e|
         message = "#{message}VALUE #{e.key} #{e.flags} #{e.bytes} #{e.cas}\r\n#{e.data}\r\n"
      }
      finalString = "#{message}END\r\n"
    end
    return finalString
  end
#Storage Commands: <command name> <key> <flags> <exptime> <bytes> [noreply]\r\n
  def storageHandler(commandLine,client,command)
    response = Array.new(2,true)
      case command
      when "set"
        command,key,flags,exptime,bytes,noreply = commandLine.split(/ /)
        dataBlock = client.read(bytes.to_i + 2).chomp
        response[1] = self.memoryCache.set(key,flags,exptime,dataBlock,bytes)
      when "add"
        command,key,flags,exptime,bytes,noreply = commandLine.split(/ /)
        dataBlock = client.read(bytes.to_i + 2).chomp
        response[1] = self.memoryCache.add(key,flags,exptime,dataBlock,bytes)
      when "replace"
        command,key,flags,exptime,bytes,noreply = commandLine.split(/ /)
        dataBlock = client.read(bytes.to_i + 2).chomp
        response[1] = self.memoryCache.replace(key,flags,exptime,dataBlock,bytes)
      when "append"
        command,key,bytes = commandLine.split(/ /)
        dataBlock = client.read(bytes.to_i + 2).chomp
        response[1] = self.memoryCache.append(key,dataBlock,bytes)
      when "prepend"
        command,key,bytes = commandLine.split(/ /)
        dataBlock = client.read(bytes.to_i + 2).chomp
        response[1] = self.memoryCache.prepend(key,dataBlock,bytes)
      when "cas"
        command,key,flags,exptime,bytes,cas,noreply = commandLine.split(/ /)
        dataBlock = client.read(bytes.to_i + 2).chomp
        response[1] = self.memoryCache.cas(key,flags,exptime,bytes,cas.to_i,dataBlock)
      end
    #noreply evaluation
    condition = noreply.eql? "0"
    if !condition
      response[0] = false unless noreply.nil?
    end
    return response
  end
end#class
