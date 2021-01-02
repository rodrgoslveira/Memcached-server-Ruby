require 'socket'
require_relative 'memCachedModules'


class MemCacheServer
  attr_accessor :port, :serverSocket, :memoryCache
  def initialize(portToListen)
    @port = portToListen
    @memoryCache = MemCached.new
    @serverSocket = TCPServer.open(portToListen) #Socket to Listen on portToListen
    puts "opening Server Socket at Port #{self.port}"
  end

  def runServerToListen
    puts "Server ready to listen"
      serverFlag = true
      while serverFlag

          Thread.start(self.serverSocket.accept) do |connectionSocket|
            begin
              puts ":>Openning connection with: #{connectionSocket.to_s} "
              dataIncoming = connectionSocket.gets    # Read lines from the socket
              #dataIncoming = connectionSocket.read
            #  puts "dataIncoming: #{dataIncoming}"
              flag = false
              flag = true unless dataIncoming.nil?
              response = self.requestHandler(dataIncoming.chop,connectionSocket) unless dataIncoming.nil?
              if (flag && response[0]) #check if the client wants reply from the server
                puts ":>Sending:\n #{response[1]}"
                connectionSocket.puts(response[1])         # Send the response to the client
              end
              connectionSocket.close                  # Disconnect from the client
            rescue Exception => e
              errorMssg = "SERVER_ERROR an error ocurred, closing connection\r\n"
              connectionSocket.puts(errorMssg)         # Send the response to the client
              connectionSocket.close                  # Disconnect from the client
              puts ":>EXCEPTION: #{e.inspect}"
              puts ":>MESSAGE: #{e.message}"
              puts ":>LOCATION:#{e.backtrace_locations}"
            end
          end

      end
  end

  def requestHandler(dataIncoming,client)
    command = dataIncoming.split(/ /)
    message = ""
    checkReply = true
    case command[0]
    when "get"
      message = self.retrievalHandler(dataIncoming)
      checkReply = false
    when "gets"
      message = self.retrievalHandler(dataIncoming)
      checkReply = false
    when "set"
      message = self.storageHandler(dataIncoming,client)
    when "add"
      message = self.storageHandler(dataIncoming,client)
    when "replace"
      message = self.storageHandler(dataIncoming,client)
    when "append"
      message = self.storageHandler(dataIncoming,client)
    when "prepend"
      message = self.storageHandler(dataIncoming,client)
    when "cas"
      message = self.storageHandler(dataIncoming,client)
    else
      message = "CLIENT_ERROR nonexistent command name\r\n"
      checkReply = false
    end
    arrResponse = Array.new(2,true)
    arrResponse[1] = message
    if checkReply
        arrResponse[1] = message[1] #for sure message will be an array
        if !message[0]
            arrResponse[0] = false
        end
    end
    return arrResponse
  end

  def retrievalHandler(requestIncoming)
    command = requestIncoming.split(/ /,2)
    keys = command[1].split(/ /)
    result = []
    case command[0]
    when "get"
      result = self.memoryCache.get(keys)
    when "gets"
      result = self.memoryCache.gets(keys)
    end
  #  VALUE <key> <flags> <bytes> [<cas unique>]\r\n
  #  <data block>\r\n
    message = ""

    result.each{ |e|

       message = "#{message}VALUE #{e.key} #{e.bytes} #{e.bytes}\r\n#{e.data}\r\n"
    }

    finalString = "#{message}END\r\n"
    return finalString
  end

  def storageHandler(requestIncoming,client)
  #  <command name> <key> <flags> <exptime> <bytes> [noreply]\r\n
    commandLine = requestIncoming
    command,key,flags,exptime,bytes,noreply = commandLine.split(/ /)
    dataBlock = client.read(bytes.to_i).chomp
    response = Array.new(2,true)
      #critical section
      case command
      when "set"
        response[1] = self.memoryCache.set(key,flags,exptime,dataBlock,bytes)
      when "add"
        response[1] = self.memoryCache.add(key,flags,exptime,dataBlock,bytes)
      when "replace"
        response[1] = self.memoryCache.replace(key,flags,exptime,dataBlock,bytes)
      when "append"
        response[1] = self.memoryCache.append(key,dataBlock,bytes)
      when "prepend"
        response[1] = self.memoryCache.prepend(key,dataBlock,bytes)
      when "cas"
        response[1] = self.memoryCache.cas(dataIncoming)
      end

    #noreply evaluation
    #puts "noreply: #{noreply}"
    condition = noreply.eql? "0"
    if !condition
      response[0] = false unless noreply.nil?
    end
    return response
  end


end
