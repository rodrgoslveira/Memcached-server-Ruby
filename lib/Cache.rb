require_relative 'MemCached'

class Cache
  include DataTypeModule
  def initialize
    @memoryCacheThreadSafe = MemCacheTSC.new
  end
#--------------------------------------------RETRIEVAL COMMANDS
  def get(keys)
    result = []
    if keys.instance_of? Array #case key*
      return getSetItems(keys)
    else
      return getItem(keys)
    end
  end

  def gets(keys)
    get(keys) #equal with the difference of cas that is responsability of MemCachedServer
  end
#--------------------------------------------STORAGE COMMANDS
 #  "set" means "store this data".
  def set(key,flags,exptime,data,bytes)
    bucket = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
    bucket.lock.synchronize{
    if bucket.hash.has_key?(key)
      item = CacheDataType.new(key,data,flags,exptime,bytes,generateCas(bucket.hash[key].cas))
      bucket.hash.store(key,item)
    else
      item = CacheDataType.new(key,data,flags,exptime,bytes,generate_Cas)
      bucket.hash.store(key,item)
    end
    }
      return "STORED\r\n"
  end
  #  "add" means "store this data, but only if the server *doesn't* already
  #  hold data for this key".
  def add(key,flags,exptime,data,bytes)
    bucket = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
    if bucket.hash.has_key?(key)
      return "NOT_STORED\r\n"
    else
      bucket.lock.synchronize{
      item = CacheDataType.new(key,data,flags,exptime,bytes,generate_Cas)
      bucket.hash.store(key,item)
      }
      return "STORED\r\n"
    end
  end
  # "replace" means "store this data, but only if the server *does*
  # already hold data for this key".
  def replace(key,flags,exptime,data,bytes)
    bucket = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
    if bucket.hash.has_key?(key)
      bucket.lock.synchronize{
      item = CacheDataType.new(key,data,flags,exptime,bytes,generateCas(bucket.hash[key].cas))
      bucket.hash.store(key,item)
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
    bucket = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
    if bucket.hash.has_key?(key)
      bucket.lock.synchronize{
        oldItem = bucket.hash[key]
        newData = "#{oldItem.data}#{data}"
        newBytes = oldItem.bytes + bytes
        item = CacheDataType.new(oldItem.key,newData,oldItem.flags,oldItem.exptime,newBytes,generateCas(oldItem.cas))
        bucket.hash.store(key,item)
      }
      return "STORED\r\n"
    else
      return "NOT_STORED\r\n"
    end
  end
  # "prepend" means "add this data to an existing key before existing data".
  def prepend(key,data,bytes)
    bucket = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
    if bucket.hash.has_key?(key)
      bucket.lock.synchronize{
        oldItem = bucket.hash[key]
        newData = "#{data}#{oldItem.data}"
        newBytes = oldItem.bytes + bytes
        item = CacheDataType.new(oldItem.key,newData,oldItem.flags,oldItem.exptime,newBytes,generateCas(oldItem.cas))
        bucket.hash.store(key,item)
      }
      return "STORED\r\n"
    else
      return "NOT_STORED\r\n"
    end
  end
  # "cas" is a check and set operation which means "store this data but
  # only if no one else has updated since I last fetched it."
  def cas(key,flags,exptime,bytes,cas_unique,data)
    bucket = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
    bucket.lock.synchronize{
      item = bucket.hash[key]
      return "NOT_FOUND\r\n" if item.nil?
      oldCas = item.cas
      return "EXISTS\r\n" unless oldCas == cas_unique
      newItem = CacheDataType.new(key,data,flags,exptime,bytes,cas_unique)
      bucket.hash.store(key,newItem)
      return "STORED\r\n"
    }
  end
 #--------------------------------------------AUX METHODS
 private

  def checkExpTime(key)
    bucket = @memoryCacheThreadSafe.getMutexSegment(key.to_s)
    item = bucket.hash[key]
    if item.exptime.nil?
      return false
    elsif Time.new > item.exptime
      bucket.hash.delete(key)
      return true
    else
      return false
    end
  end

  def getSetItems(keys)
    result = []
    keys.each do |e|
      bucket = @memoryCacheThreadSafe.getMutexSegment(e.to_s)
      if bucket.hash.has_key?(e) #verify key and exptime
        bucket.lock.synchronize {
          if ( !( checkExpTime(e) ) )
            result.push(bucket.hash[e])
          end
        }
      end
    end
    return result
  end

  def getItem(itemKey)
    bucket = @memoryCacheThreadSafe.getMutexSegment(itemKey.to_s)
    result = []
      if bucket.hash.has_key?(itemkey) #verify key and exptime
        bucket.lock.synchronize{
          if ( !( checkExpTime(itemKey) ) )
            result.push(bucket.hash[itemKey])
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
end
