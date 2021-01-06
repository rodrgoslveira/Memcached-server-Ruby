module DataTypeModule
   class CacheDataType
     attr_reader :key, :data, :flags, :exptime, :bytes, :cas, :semaphore
     def initialize(itemKey, itemData, itemFlags, itemExptime,itemBytes,itemCas)
       @key = itemKey
       @data = itemData
       @flags = itemFlags
       @exptime = self.getExpTimeValue(itemExptime)
       @bytes = itemBytes
       @cas = itemCas
     end

     def getExpTimeValue(seconds)
       seconds = seconds.to_i
       if seconds == 0
         return nil
       elsif ( ( seconds < (60*60*24*30) ) )
         return Time.new + seconds
       else
         return Time.at(seconds)
       end
     end

   end#class
   #works for MemCachedClient.gets
   class CasDataType
     attr_reader :cas, :data
     def initialize(itemCas, itemData)
       @cas = itemCas
       @data = itemData
     end
   end
end#module
