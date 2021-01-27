#This class has the responsability of making memcached thread safe
#by implementing multiple Segment level locks.
require_relative 'memcached'

class MemCacheTSC
  include DataTypeModule

  attr_accessor :locks_segments

  def initialize
    @locks_segments = []
    17.times do |i|
      locks_segments[i] = Bucket.new(Mutex.new, Hash.new)
    end
  end
  
  def get_mutex_segment(key)
    hash_function = key.length % 17 #its better to evaluate the type of keys that will income, then decide wich hash function use
    @locks_segments[hash_function]
  end
end
