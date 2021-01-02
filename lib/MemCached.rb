require_relative 'memCachedModules'

class MemCached
  def initialize
    @HashCache = {}
    @memoryCacheThreadSafe = MemCacheTSC.new
  end
#--------------------------------------------RETRIEVAL COMMANDS

# Each item sent by the server looks like this:
# VALUE <key> <flags> <bytes> [<cas unique>]\r\n
# <data block>\r\n
# After all the items have been transmitted, the server sends the string
#"END\r\n"
  def gets(itemKey)
    result = []
    if itemKey.instance_of? Array #case key*
        itemKey.each do |e|
            semaphore = @memoryCacheThreadSafe.getMutexSegment(e.to_s)
            semaphore.synchronize {
                if @HashCache.has_key?(e) #verify key and exptime
                    if ( !( checkExpTime(e) ) )
                      result.push( @HashCache[e] )
                    end
                end
            }
        end
    else #case only one key
        semaphore = @memoryCacheThreadSafe.getMutexSegment(itemKey.to_s)
        semaphore.synchronize{
          if @HashCache.has_key?(itemkey) # verify key and exptime
              if ( !( checkExpTime(itemKey) ) )
                result.push( @HashCache[itemKey] )
              end
          end
         }
        return result
    end
  end

  def get(itemKey)
    result = []
    if itemKey.instance_of? Array #case key*
        itemKey.each do |e|
            semaphore = @memoryCacheThreadSafe.getMutexSegment(e.to_s)
            semaphore.synchronize {
                if @HashCache.has_key?(e) #verify key and exptime
                    if ( !( checkExpTime(e) ) )

                      result.push(@HashCache[e])

                    end
                end
            }
        end
    else #case only one key
        semaphore = @memoryCacheThreadSafe.getMutexSegment(itemKey.to_s)
        semaphore.synchronize{
          if @HashCache.has_key?(itemkey) #verify key and exptime
              if ( !( checkExpTime(itemKey) ) )
                result.push(@HashCache[itemKey])
              end
          end
         }
    end
    return result
  end

#--------------------------------------------STORAGE COMMANDS

#Storage Commands: <command name> <key> <flags> <exptime> <bytes> [noreply]\r\n
 #  "set" means "store this data".
  def set(key,flags,exptime,data,bytes)
    semaphore = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
    semaphore.synchronize{
    item = CacheDataType.new(key,data,flags,exptime,bytes)
    @HashCache.store(key,item)
    }
    return "STORED\r\n"
  end
  #  "add" means "store this data, but only if the server *doesn't* already
  #  hold data for this key".
  def add(key,flags,exptime,data,bytes)
    semaphore = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
    semaphore.synchronize{
    if @HashCache.has_key?(key)
      return "NOT_STORED\r\n"
    else
      item = CacheDataType.new(key,data,flags,exptime,bytes)
      @HashCache.store(key,item)
      return "STORED\r\n"
    end
  }
  end
  # "replace" means "store this data, but only if the server *does*
  # already hold data for this key".
  def replace(key,flags,exptime,data,bytes)
    semaphore = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
    semaphore.synchronize{
    if @HashCache.has_key?(key)
      item = CacheDataType.new(key,data,flags,exptime,bytes)
      @HashCache.store(key,item)
      return "STORED\r\n"
    else
      return "NOT_STORED\r\n"
    end
  }
  end
  # The append and prepend commands do not accept flags or exptime.
  # They update existing data portions, and ignore new flag and exptime
  # settings.
  # "append" means "add this data to an existing key after existing data"
  def append(key,data,bytes)
    semaphore = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
    semaphore.synchronize{
    if @HashCache.has_key?(key)
      oldItem = @HashCache[key]
      newData = "#{oldItem.data}#{data}"
      item = CacheDataType.new(oldItem.key,newData,oldItem.flags,oldItem.exptime,bytes)
      @HashCache.store(key,item)
      return "STORED\r\n"
    else
      return "NOT_STORED\r\n"
    end
  }
  end
  # "prepend" means "add this data to an existing key before existing data".
  def prepend(key,data,bytes)
    semaphore = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
    semaphore.synchronize{
    if @HashCache.has_key?(key)
      oldItem = @HashCache[key]
      newData = "#{data}#{oldItem.data}"
      item = CacheDataType.new(oldItem.key,newData,oldItem.flags,oldItem.exptime,bytes)
      @HashCache.store(key,item)
      return "STORED\r\n"
    else
      return "NOT_STORED\r\n"
    end
  }
  end
  # "cas" is a check and set operation which means "store this data but
  # only if no one else has updated since I last fetched it."
  def cas
    #last
  end
 #--------------------------------------------AUX METHODS
  def checkExpTime(key)
    item = @HashCache[key]
    if Time.new > item.exptime
      @HashCache.delete(key)
      return true
    else
      return false
    end
  end
end #class
