require_relative 'MemCached'

class Cache
  include DataTypeModule
  def initialize
    @HashCache = {}
    @memoryCacheThreadSafe = MemCacheTSC.new
  end
#--------------------------------------------RETRIEVAL COMMANDS
  def get(keys)
    result = []
    if keys.instance_of? Array #case key*
      return getSetItems(keys)
    else #case only one key
      return getItem(keys)
    end
  end

  def gets(keys)
    get(keys) #equal with the difference of cas that is responsability of MemCachedServer
  end

#--------------------------------------------STORAGE COMMANDS

 #  "set" means "store this data".
  def set(key,flags,exptime,data,bytes)
    mutex = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
    mutex.synchronize{
    if @HashCache.has_key?(key)
      item = CacheDataType.new(key,data,flags,exptime,bytes,generateCas(@HashCache[key].cas))
      @HashCache.store(key,item)

    else
      item = CacheDataType.new(key,data,flags,exptime,bytes,generate_Cas)
      @HashCache.store(key,item)
    end
    }
      return "STORED\r\n"
  end
  #  "add" means "store this data, but only if the server *doesn't* already
  #  hold data for this key".
  def add(key,flags,exptime,data,bytes)
    if @HashCache.has_key?(key)
      return "NOT_STORED\r\n"
    else
      mutex = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
      mutex.synchronize{
      item = CacheDataType.new(key,data,flags,exptime,bytes,generate_Cas)
      @HashCache.store(key,item)
      }
      return "STORED\r\n"
    end
  end
  # "replace" means "store this data, but only if the server *does*
  # already hold data for this key".
  def replace(key,flags,exptime,data,bytes)
    if @HashCache.has_key?(key)
      mutex = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
      mutex.synchronize{
      item = CacheDataType.new(key,data,flags,exptime,bytes,generateCas(@HashCache[key].cas))
      @HashCache.store(key,item)
      }
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
      mutex = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
      mutex.synchronize{
      oldItem = @HashCache[key]
      newData = "#{oldItem.data}#{data}"
      newBytes = oldItem.bytes + bytes
      item = CacheDataType.new(oldItem.key,newData,oldItem.flags,oldItem.exptime,newBytes,generateCas(oldItem.cas))
      @HashCache.store(key,item)
      }
      return "STORED\r\n"
    else
      return "NOT_STORED\r\n"
    end
  end
  # "prepend" means "add this data to an existing key before existing data".
  def prepend(key,data,bytes)
    if @HashCache.has_key?(key)
      mutex = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
      mutex.synchronize{
      oldItem = @HashCache[key]
      newData = "#{data}#{oldItem.data}"
      newBytes = oldItem.bytes + bytes
      item = CacheDataType.new(oldItem.key,newData,oldItem.flags,oldItem.exptime,newBytes,generateCas(oldItem.cas))
      @HashCache.store(key,item)
      }
      return "STORED\r\n"
    else
      return "NOT_STORED\r\n"
    end
  end
  # "cas" is a check and set operation which means "store this data but
  # only if no one else has updated since I last fetched it."
  def cas(key,flags,exptime,bytes,cas_unique,data)
    mutex = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
    mutex.synchronize{
    item = @HashCache[key]
    return "NOT_FOUND\r\n" if item.nil?
    oldCas = item.cas
    return "EXISTS\r\n" unless oldCas == cas_unique
    newItem = CacheDataType.new(key,data,flags,exptime,bytes,cas_unique)
    @HashCache.store(key,newItem)
    return "STORED\r\n"
    }
  end
 #--------------------------------------------AUX METHODS
 private

  def checkExpTime(key)
    item = @HashCache[key]
    if item.exptime.nil?
      return false
    elsif Time.new > item.exptime
      @HashCache.delete(key)
      return true
    else
      return false
    end
  end

  def getSetItems(keys)
    result = []
    keys.each do |e|
      if @HashCache.has_key?(e) #verify key and exptime
        mutex = @memoryCacheThreadSafe.getMutexSegment(e.to_s)
        mutex.synchronize {
          if ( !( checkExpTime(e) ) )
            result.push(@HashCache[e])
          end
        }
      end
    end
    return result
  end

  def getItem(itemKey)
    result = []
      if @HashCache.has_key?(itemkey) #verify key and exptime
        mutex = @memoryCacheThreadSafe.getMutexSegment(itemkey.to_s)
        mutex.synchronize{
          if ( !( checkExpTime(itemKey) ) )
            result.push(@HashCache[itemKey])
          end
        }
      end
     return result
  end
  def generate_Cas
    rand(100000)
  end
  def generateCas(value)
    rand(100000) + value
  end
end #class
