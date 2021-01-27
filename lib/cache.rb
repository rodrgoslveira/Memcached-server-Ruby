require_relative 'memcached'

class Cache
  include DataTypeModule
  include Response

  def initialize
    @mc_thread_safe = MemCacheTSC.new
    @cas_id = 1
    @cas_id_lock = Mutex.new
  end
#--------------------------------------------RETRIEVAL COMMANDS
  def get(keys)
    if keys.instance_of? Array #case key*
      generate_retrival_response(get_set_items(keys), false)
    else
      generate_retrival_response(get_item(keys), false)
    end
  end

  def gets(keys)
    if keys.instance_of? Array #case key*
      generate_retrival_response(get_set_items(keys), true)
    else
      generate_retrival_response(get_item(keys), true)
    end
  end
#--------------------------------------------STORAGE COMMANDS
 #  "set" means "store this data".
  def set(key, flags, exp_time, data, bytes)
    check_exp_time(key)
    bucket = @mc_thread_safe.get_mutex_segment(key.to_s)
    bucket.lock.synchronize{
      item = CacheDataType.new(key, data, flags, exp_time, bytes, get_cas_id)
      bucket.hash.store(key, item)
    }
    Response::STORED
  end
  #  "add" means "store this data, but only if the server *doesn't* already
  #  hold data for this key".
  def add(key, flags, exp_time, data, bytes)
    check_exp_time(key)
    bucket = @mc_thread_safe.get_mutex_segment(key.to_s)
    if bucket.hash.has_key?(key)
      Response::NOT_STORED
    else
      bucket.lock.synchronize{
      item = CacheDataType.new(key, data, flags, exp_time, bytes, get_cas_id)
      bucket.hash.store(key, item)
      }
      Response::STORED
    end
  end
  # "replace" means "store this data, but only if the server *does*
  # already hold data for this key".
  def replace(key, flags, exp_time, data, bytes)
    check_exp_time(key)
    bucket = @mc_thread_safe.get_mutex_segment(key.to_s)
    if bucket.hash.has_key?(key)
      bucket.lock.synchronize{
      item = CacheDataType.new(key, data, flags, exp_time, bytes, get_cas_id)
      bucket.hash.store(key,item)
      }
      Response::STORED
    else
      Response::NOT_STORED
    end
  end
  # The append and prepend commands do not accept flags or exp_time.
  # They update existing data portions, and ignore new flag and exp_time
  # settings.
  # "append" means "add this data to an existing key after existing data"
  def append(key, data, bytes)
    check_exp_time(key)
    bucket = @mc_thread_safe.get_mutex_segment(key.to_s)
    if bucket.hash.has_key?(key)
      bucket.lock.synchronize{
        old_item = bucket.hash[key]
        new_data = "#{old_item.data}#{data}"
        new_bytes = old_item.bytes + bytes
        item = CacheDataType.new(old_item.key, new_data, old_item.flags, old_item.exp_time, new_bytes, get_cas_id)
        bucket.hash.store(key, item)
      }
      Response::STORED
    else
      Response::NOT_STORED
    end
  end
  # "prepend" means "add this data to an existing key before existing data".
  def prepend(key, data, bytes)
    check_exp_time(key)
    bucket = @mc_thread_safe.get_mutex_segment(key.to_s)
    if bucket.hash.has_key?(key)
      bucket.lock.synchronize{
        old_item = bucket.hash[key]
        new_data = "#{data}#{old_item.data}"
        new_bytes = old_item.bytes + bytes
        item = CacheDataType.new(old_item.key, new_data, old_item.flags, old_item.exp_time, new_bytes, get_cas_id)
        bucket.hash.store(key, item)
      }
      Response::STORED
    else
      Response::NOT_STORED
    end
  end
  # "cas" is a check and set operation which means "store this data but
  # only if no one else has updated since I last fetched it."
  def cas(key, flags, exp_time, bytes, cas_unique, data)
    check_exp_time(key)
    bucket = @mc_thread_safe.get_mutex_segment(key.to_s)
    bucket.lock.synchronize{
      item = bucket.hash[key]
      return Response::NOT_FOUND if item.nil?
      oldCas = item.cas
      return Response::EXISTS unless oldCas == cas_unique
      newItem = CacheDataType.new(key, data, flags, exp_time, bytes, cas_unique)
      bucket.hash.store(key, newItem)
      return Response::STORED
    }
  end
 #--------------------------------------------AUX METHODS
 private

  def check_exp_time(key)
    bucket = @mc_thread_safe.get_mutex_segment(key.to_s)
    if bucket.hash.has_key?(key)
      item = bucket.hash[key]
      result = if item.exp_time.nil?
                false
               elsif Time.new > item.exp_time
                 bucket.hash.delete(key)
                 true
               else
                 false
               end
    end
  end

  def get_set_items(keys)
    result = []
    keys.each do |e|
      bucket = @mc_thread_safe.get_mutex_segment(e.to_s)
      if bucket.hash.has_key?(e) #verify key and exp_time
        bucket.lock.synchronize {
          if ( !( check_exp_time(e) ) )
            result.push(bucket.hash[e])
          end
        }
      end
    end
    return result
  end
  
  def get_item(itemKey)
    bucket = @mc_thread_safe.get_mutex_segment(itemKey.to_s)
    result = []
      if bucket.hash.has_key?(itemkey) #verify key and exp_time
        bucket.lock.synchronize{
          if ( !( check_exp_time(itemKey) ) )
            result.push(bucket.hash[itemKey])
          end
        }
      end
    return result
  end

  def get_cas_id
    @cas_id_lock.synchronize {
      @cas_id += 1
    }
  end

end
