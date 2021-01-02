   class CacheDataType
     attr_reader :key, :data, :flags, :exptime, :bytes
     def initialize(itemKey, itemData, itemFlags, itemExptime,itemBytes)
       @key = itemKey
       @data = itemData
       @flags = itemFlags
       @exptime = self.getExpTimeValue(itemExptime)
       @bytes = itemBytes
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
