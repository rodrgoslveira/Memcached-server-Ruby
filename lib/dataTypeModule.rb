module dataTypeModule
   class CacheDataType
     attr_reader :key, :data, :flags, :exptime, :bytes
     def initialize(itemKey, itemData, itemFlags, itemExptime,itemBytes)
       @key = itemKey
       @data = itemData
       @flags = itemFlags
       @exptime = itemExptime
       @bytes = itemBytes
     end
   end
end
