require 'socket'
require_relative 'memCachedModules'
require_relative 'MemCached'
require_relative 'MemCachedTSC'

class MemCacheServer
  attr_accessor :port, :serverSocket, :memoryCache
  def initialize(portToListen)
    @port = portToListen
    @memoryCache = MemCached.new
    @memoryCacheThreadSafe = MemCacheTSC.new
    @serverSocket = TCPServer.open(portToListen) #Socket to Listen on portToListen
    puts "opening Server Socket at Port #{self.port}"
  end

  def runServerToListen
      serverFlag = true
      while serverFlag

          Thread.start(self.serverSocket.accept) do |connectionSocket|
            begin
              dataIncoming = connectionSocket.gets.chop    # Read lines from the socket
            #  puts "dataIncoming: #{dataIncoming}"
              response = self.requestHandler dataIncoming
              if response[0] #check if the client wants reply from the server
                puts "Sending: #{response[1]}"
                connectionSocket.puts(response[1])         # Send the response to the client
              end
              connectionSocket.close                  # Disconnect from the client
            rescue Exception => e
              errorMssg = "SERVER_ERROR an error ocurred, try again\r\n"
              connectionSocket.puts(errorMssg)         # Send the response to the client
              connectionSocket.close                  # Disconnect from the client
              puts "EXCEPTION: #{e.inspect}"
              puts "MESSAGE: #{e.message}"
            end
          end

      end
  end

  def requestHandler(dataIncoming)
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
      message = self.storageHandler(dataIncoming)
    when "add"
      message = self.storageHandler(dataIncoming)
    when "replace"
      message = self.storageHandler(dataIncoming)
    when "append"
      message = self.storageHandler(dataIncoming)
    when "prepend"
      message = self.storageHandler(dataIncoming)
    when "cas"
      message = self.storageHandler(dataIncoming)
    else
      message = "CLIENT_ERROR nonexistent command name\r\n"
    end
    arrResponse = Array.new(2,true)
    arrResponse[1] = message
    if checkReply
        arrResponse[1] = message[1]
        if !message[0]
        end
         arrResponse[0] = false
    end
    return arrResponse

  end

  def retrievalHandler(requestIncoming)
    command = requestIncoming.split(/ /,2)
    keys = command[1].split(/ /)
    result = []
    keys.each { |k|
      semaphore = @memoryCacheThreadSafe.getMutexSegment(k.to_s)
      semaphore.synchronize {
        #critical section
        case command[0]
        when "get"
          result.push(self.memoryCache.get(k))
        when "gets"
          result.push(self.memoryCache.get(k))
        end
      }
    }
  #  VALUE <key> <flags> <bytes> [<cas unique>]\r\n
  #  <data block>\r\n
  message = ""
    result.each { |e|
       message = "#{message}VALUE #{e.key} #{e.bytes} #{e.bytes}\r\n#{e.data}\r\n"
    }

    finalString = "#{message}END\r\n"

    return finalString
  end

  def storageHandler(requestIncoming)
  #  <command name> <key> <flags> <exptime> <bytes> [noreply]\r\n
    commandLine,dataBlock = requestIncoming.split("\r\n",2)
    puts "StoraGE HANDEL"
    puts commandLine
    puts dataBlock
    puts "Finish"
    command,key,flags,exptime,bytes,noreply = commandLine.split(/ /)
    response = Array.new(2,true)
    puts "command at storageHandler: #{command}"
    semaphore = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
    semaphore.synchronize {
      #critical section
      case command
      when "set"
        response[1] = self.memoryCache.set(key,flags,exptime,dataBlock,bytes)
      when "add"
        response[1] = self.storageHandler(dataIncoming)
      when "replace"
        response[1] = self.storageHandler(dataIncoming)
      when "append"
        response[1] = self.storageHandler(dataIncoming)
      when "prepend"
        response[1] = self.storageHandler(dataIncoming)
      when "cas"
        response[1] = self.storageHandler(dataIncoming)
      end
    }
    #noreply evaluation
    condition = noreply.eql? "1"
    if !condition
      response[0] = false
    end
    return response

  end


end
