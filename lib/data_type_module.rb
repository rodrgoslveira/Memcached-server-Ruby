module DataTypeModule
  class CacheDataType
    attr_reader :key, :data, :flags, :exp_time, :bytes, :cas, :semaphore

    def initialize(key, data, flags, item_exp_time, bytes, cas)
      @key = key
      @data = data
      @flags = flags
      @exp_time = self.get_exp_time_value(item_exp_time)
      @bytes = bytes
      @cas = cas
    end

    def get_exp_time_value(seconds)
      seconds = seconds.to_i
      if seconds == 0
        nil
      elsif ( ( seconds < (60*60*24*30) ) )
        Time.new + seconds
      else
        Time.at(seconds)
      end
    end
  end
#This class works for MemCachedClient.gets
  class CasDataType
    attr_reader :cas, :data

    def initialize(cas, data)
      @cas = cas
      @data = data
    end
  end
  class Bucket
    attr_accessor :lock, :hash

    def initialize(lock, hash)
      @lock = lock
      @hash = hash
    end
  end
end
