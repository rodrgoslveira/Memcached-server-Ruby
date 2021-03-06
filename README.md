# Memcached-server-Ruby
Simple memcached implementation.
### Table of Contents.

- [Description](#description)
- [How To Use](#how-to-use)
- [Details](#details)
- [Test](#test)
- [Author Info](#author-info)


---

## Description

This basic implementation of memcached:

- Memcached Server(TCP/IP socket).
- Memcached Client(TCP/IP socket).

Has been implemented for [moove it coding challenges](https://github.com/moove-it/coding-challenges/blob/master/ruby.md)

#### Commands Implemented

Retrieval commands:

* get
* gets

Storage commands:

* set
* add
* replace
* append
* prepend
* cas


#### Technologies

- Ruby


[Back To The Top](#Memcached-server-Ruby)

---

## How To Use

   To use Memcached we have to require lib/memcached.rb and include DataTypeModule
    
#### MemCachedServer

   We have to define the host and port for the Socket to listen then we use the method called "run_server_to_listen" so that    the server can listen for a client.

```ruby
  server = MemCacheServer.new('127.0.0.53',2000)
  server.run_server_to_listen
```
#### MemCachedClient
   First we need the server to be running,then we can define the host and port for the Socket.
   Here are some basic examples.
  
   - Example one: 
   
```ruby
  client = MemCacheClient.new('127.0.0.53',2000)  #=> Opening Client connection
  client.set("key1","0","0","MainData".bytesize,"MainData") #=> STORED
  cas_id = client.gets("key1").cas  #=> some_cas_value
  client.cas("key1","0","3600","Data-Changed".bytesize,cas_id,"Data-Changed")  #=> STORED
  client.get("key1")  #=> Data-Changed
  client.shutdown  #=> Closing Client connection
```
   - Example two:
   
```ruby
  client = MemCacheClient.new('127.0.0.53',2000)  #=> Opening Client connection
  client.set("key7","0","5","MainData".bytesize,"MainData") #=> "STORED"
  client.append("key7","-RightData".bytesize,"-RightData") #=> "STORED"
  client.prepend("key7","LeftData-".bytesize,"LeftData-") #=> "STORED"
  client.get("key7") #=> "LeftData-MainData-RightData"
  client.shutdown
```
   - Example three:
   
```ruby
  client = MemCacheClient.new('127.0.0.53',2000)  #=> Opening Client connection
  client.set("key2","0","0","MainData2".bytesize,"MainData2") #=> STORED
  client.set("key3","0","0","MainData3".bytesize,"MainData3") #=> STORED
  client.set("key4","0","0","MainData4".bytesize,"MainData4") #=> STORED
  client.get("key2 key3 key4") #=> [MainData2,MainData3,MainData4]
  client.shutdown  #=> Closing Client connection
```

#### Console

First Console |
------------ | 
 ![Server execution](https://github.com/rodrgoslveira/Memcached-server-Ruby/blob/main/images/MemcachedServer-example.jpg) | 
 
Second Console|
------------ | 
  ![Client execution](https://github.com/rodrgoslveira/Memcached-server-Ruby/blob/main/images/MemcachedClient-example.jpg)| 


[Back To The Top](#Memcached-server-Ruby)

---
## Details

#### Synchronization Mechanisms 

   Managing multiple clients and making Memcached thread safe was a challenge. The priority is simplicity, safety and perfomance.
   A first and more common approach was to use coarse-grained locking, thread safety provided by a single global cache lock but          this aproach could have a significant performance penalty.
   
   In order to optimize memchached perfomance,I investigated techniques to minimize or eliminate the global cache lock.
   
   The option that i have chosen for this implementation is:
   
   -Implement Segments locks which are required to set/read the memcached.
   
   The access to this segments depends on a hash function that takes the key as parameter.
   
   Simple diagram:
   
   ![Segmented locks](https://github.com/rodrgoslveira/Memcached-server-Ruby/blob/main/images/Segmented-locks.jpg)
   
   The disadvantage of this approach is that multiple frequently accessed cache items in a single segment can produce performance        penalty
   
#### MemCached Design

   ![DCD](https://github.com/rodrgoslveira/Memcached-server-Ruby/blob/main/images/DCD.jpg)
    
[Back To The Top](#Memcached-server-Ruby)
---
## Test


:warning:	 We need the server (MemCachedServer) to be running.

* Console command : ruby mc_test.rb


[Back To The Top](#Memcached-server-Ruby)

---
## Author Info

Email: rodrgoslveira@gmail.com

[Back To The Top](#Memcached-server-Ruby)
