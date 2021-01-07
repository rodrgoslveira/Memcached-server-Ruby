#This class has the responsability of making memcached thread safe
#by implementing multiple Segment level locks.
require_relative 'MemCached'

class MemCacheTSC
  include DataTypeModule
  attr_accessor :locksSegments
  def initialize
    @locksSegments = []
    17.times do |i|
      locksSegments[i] = Bucket.new(Mutex.new,Hash.new)
    end
  end
  def getMutexSegment(key)
    hashFunction = key.length % 17 #its better to evaluate the type of keys that will income, then decide wich hash function use
    return @locksSegments[hashFunction]
  end
  def flagSemaphore(key)
    result = false
    stringKey = "#{key}"
    semaphore = getMutexSegment(stringKey)
    semaphore.synchronize {
      result = true
    }
    return result
  end
end
