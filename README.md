# Memcached-server-Ruby
Simple memcached implementation.
### Table of Contents.

- [Description](#description)
- [How To Use](#how-to-use)
- [Details](#details)
- [Author Info](#author-info)

---

## Description

This basic implementation of memcached:
- Memcached Server(TCP/IP socket).
- Memcached Client(TCP/IP socket).
has been implemented for [moove it coding challenges](https://github.com/moove-it/coding-challenges/blob/master/ruby.md)

#### Technologies

- Ruby


[Back To The Top](#Memcached-server-Ruby)

---

## How To Use

   To use Memcached we have to require lib/MemChached.rb and include DataTypeModule
    
#### MemCachedServer

    We have to define the host and port for the Socket to listen and then say the server to listen.

```ruby
  server = MemCacheServer.new('127.0.0.53',2000)
  server.runServerToListen
```
#### MemCachedClient
    First we need the server to be running, after that we can define the host and port for the Socket.
    Here are some basic examples.
    
    - Example one:    
```ruby
  cliente = MemCacheClient.new('127.0.0.53',2000)  #=> Opening Client connection
  cliente.set("key1","wr","0","MainData".bytesize,"MainData") #=> STORED
  cas_id = cliente.gets("key1").cas  #=> some_cas_value
  cliente.cas("key1","w","3600","Data-Changed".bytesize,cas_id,"Data-Changed")  #=> STORED
  cliente.get("key1")  #=> Data-Changed
  cliente.shutdown  #=> Closing Client connection
```
    - Example two:
```ruby
  cliente = MemCacheClient.new('127.0.0.53',2000)  #=> Opening Client connection
  cliente.set("key7","w","5","MainData".bytesize,"MainData") #=> "STORED"
  cliente.append("key7","-RightData".bytesize,"-RightData") #=> "STORED"
  cliente.prepend("key7","LeftData-".bytesize,"LeftData-") #=> "STORED"
  cliente.get("key7") #=> "LeftData-MainData-RightData"
  cliente.shutdown
```
    - Example three:
```ruby
  cliente = MemCacheClient.new('127.0.0.53',2000)  #=> Opening Client connection
  cliente.set("key2","wr","0","MainData2".bytesize,"MainData2") #=> STORED
  cliente.set("key3","wr","0","MainData3".bytesize,"MainData3") #=> STORED
  cliente.set("key4","wr","0","MainData4".bytesize,"MainData4") #=> STORED
  cliente.get("key2 key3 key4") #=> [MainData2,MainData3,MainData4]
  cliente.shutdown  #=> Closing Client connection
``` 
#### Console
First Console |
------------ | 
 ![Server execution](/images/MemcachedServer-example.jpg) | 
Second Console|
 ------------ | 
  ![Client execution](https://github.com/rodrgoslveira/Memcached-server-Ruby/blob/main/images/MemcachedClient-example.jpg)| 


[Back To The Top](#Memcached-server-Ruby)

---
## Details

#### MemCached Thread Safe
    explained
#### MemCached Design
    IMAGEEE
    
[Back To The Top](#Memcached-server-Ruby)

---
## Author Info

Email: rodrgoslveira@gmail.com

[Back To The Top](#Memcached-server-Ruby)
