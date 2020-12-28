class MemCacheTSC
  attr_accessor :semaphoreSegments
  def initialize
    @semaphoreSegments = []
    #initialize
    17.times do |i|
      semaphoreSegments[i] = Mutex.new
    end
  end
  def getMutexSegment(key)
    hashFunction = key.length % 17
    return self.semaphoreSegments[hashFunction]
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
