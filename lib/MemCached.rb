require_relative 'memCachedModules'
class MemCached
  def initialize
    @HashCache = {}
  end
#Retrieval Commands
# Each item sent by the server looks like this:
# VALUE <key> <flags> <bytes> [<cas unique>]\r\n
# <data block>\r\n
# After all the items have been transmitted, the server sends the string
#"END\r\n"
  def gets(itemKey)
    result = []
    itemKey.each do |e|
      result = @HashCache[e]
    end
    return result
  end

  def get(itemKey)
    result = []
    if itemKey.instance_of? Array
      itemKey.each do |e|
        result = @HashCache[e]
      end
    else
      result = @HashCache[itemKey]
    end

    return result
  end
#Storage Commands: <command name> <key> <flags> <exptime> <bytes> [noreply]\r\n

 #  "set" means "store this data".
  def set(key,flags,exptime,data,bytes)
    puts "Key at MemCached: #{key}"
    puts "Data at MemCached: #{data}"
    item = CacheDataType.new(key,data,flags,exptime,bytes)
    @HashCache.store(key,item)
    return "STORED\r\n"
  end
  #  "add" means "store this data, but only if the server *doesn't* already
  #  hold data for this key".
  def add(key,flags,exptime,data,bytes)
    if @HashCache.has_key?(key)
      return "NOT_STORED\r\n"
    else
      item = CacheDataType.new(key,data,flags,exptime,bytes)
      @HashCache.store(key,item)
      return "STORED\r\n"
    end
  end
  # "replace" means "store this data, but only if the server *does*
  # already hold data for this key".
  def replace(key,flags,exptime,data,bytes)
    if @HashCache.has_key?(key)
      item = CacheDataType.new(key,data,flags,exptime,bytes)
      @HashCache.store(key,item)
      return "STORED\r\n"
    else
      return "NOT_STORED\r\n"
    end
  end
  # The append and prepend commands do not accept flags or exptime.
  # They update existing data portions, and ignore new flag and exptime
  # settings.
  # "append" means "add this data to an existing key after existing data"
  def append(key,data,bytes)
    if @HashCache.has_key?(key)
      oldItem = @HashCache[key]
      newData = "#{oldItem.data}#{data}"
      item = CacheDataType.new(oldItem.key,newData,oldItem.flags,oldItem.exptime,bytes)
      @HashCache.store(key,item)
      return "STORED\r\n"
    else
      return "NOT_STORED\r\n"
    end
  end
  # "prepend" means "add this data to an existing key before existing data".
  def prepend(key,data,bytes)
    if @HashCache.has_key?(key)
      oldItem = @HashCache[key]
      newData = "#{data}#{oldItem.data}"
      item = CacheDataType.new(oldItem.key,newData,oldItem.flags,oldItem.exptime,bytes)
      @HashCache.store(key,item)
      return "STORED\r\n"
    else
      return "NOT_STORED\r\n"
    end
  end
  # "cas" is a check and set operation which means "store this data but
  # only if no one else has updated since I last fetched it."
  def cas
    #last
  end

end
