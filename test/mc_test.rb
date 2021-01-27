require 'minitest/autorun'
require_relative '../lib/memcached'
#the server needs to be running before the execution of this test
puts "MemCached Test-[host port]"
intro = $stdin.gets.chomp
host,port = intro.split(/ /)
describe "MemCachedClient test" do
  before do
    @mc_client = MemCacheClient.new(host,port)
  end
  it "set an item" do
    @mc_client.set("key1","w","0","MainData".bytesize,"MainData").must_equal "STORED"
    @mc_client.get("key1").must_equal "MainData"
    @mc_client.shutdown
  end
  it "try to add an item that already is stored" do
    @mc_client.set("key2","w","0","MainData".bytesize,"MainData")
    @mc_client.add("key2","w","0","Adding Data".bytesize,"Adding Data").must_equal "NOT_STORED"
    @mc_client.shutdown
  end
  it "add a new item" do
    @mc_client.add("key3","w","0","Adding Data".bytesize,"Adding Data").must_equal "STORED"
    @mc_client.get("key3").must_equal "Adding Data"
    @mc_client.shutdown
  end
  it "get the right value of an item stored" do
    @mc_client.set("keytest","w","0","MainData".bytesize,"MainData").must_equal "STORED"
    @mc_client.get("keytest").must_equal "MainData"
    @mc_client.shutdown
  end
  it "trying to get nonexistent key " do
    @mc_client.get("k").must_equal arr = []
    @mc_client.shutdown
  end
  it "replace an existing item" do
    @mc_client.set("key4","w","5","MainData".bytesize,"MainData").must_equal "STORED"
    @mc_client.replace("key4","w","5","replacedData".bytesize,"replacedData").must_equal "STORED"
    @mc_client.get("key4").must_equal "replacedData"
    @mc_client.shutdown
  end
  it "trying to replace a nonexistent item" do
    @mc_client.replace("key90","w","5","replacedData".bytesize,"replacedData").must_equal "NOT_STORED"
    @mc_client.shutdown
  end
  it "append to an existing key" do
    @mc_client.set("key5","w","5","Data".bytesize,"Data").must_equal "STORED"
    @mc_client.append("key5","-RightData".bytesize,"-RightData").must_equal "STORED"
    @mc_client.get("key5").must_equal "Data-RightData"
    @mc_client.shutdown
  end
  it "prepend to an existing key" do
    @mc_client.set("key6","w","5","Data".bytesize,"Data").must_equal "STORED"
    @mc_client.prepend("key6","LeftData-".bytesize,"LeftData-").must_equal "STORED"
    @mc_client.get("key6").must_equal "LeftData-Data"
    @mc_client.shutdown
  end
  it "append and prepend commands" do
    @mc_client.set("key7","w","5","MainData".bytesize,"MainData").must_equal "STORED"
    @mc_client.append("key7","-RightData".bytesize,"-RightData").must_equal "STORED"
    @mc_client.prepend("key7","LeftData-".bytesize,"LeftData-").must_equal "STORED"
    @mc_client.get("key7").must_equal "LeftData-MainData-RightData"
    @mc_client.shutdown
  end
  it "trying to append a nonexistent item" do
    @mc_client.append("key8","-RightData".bytesize,"-RightData").must_equal "NOT_STORED"
    @mc_client.shutdown
  end
  it "trying to prepend a nonexistent item" do
    @mc_client.prepend("key9","LeftData-".bytesize,"LeftData-").must_equal "NOT_STORED"
    @mc_client.shutdown
  end
  it "cas command, right situation" do
    @mc_client.set("key10","w","5","MainData".bytesize,"MainData").must_equal "STORED"
    cas_token = @mc_client.gets("key10").cas
    @mc_client.cas("key10","w","5","CAS_MainData".bytesize,cas_token,"CAS_MainData").must_equal "STORED"
    @mc_client.get("key10").must_equal "CAS_MainData"
    @mc_client.shutdown
  end
  it "cas command, wrong situation" do
    @mc_client.set("key11","w","5","MainData".bytesize,"MainData").must_equal "STORED"
    cas_token = @mc_client.gets("key11").cas
    @mc_client.set("key11","w","5","MainData".bytesize,"MainData").must_equal "STORED"
    @mc_client.cas("key11","w","5","CAS_Data".bytesize,cas_token,"CAS_Data").must_equal "EXISTS"
    @mc_client.shutdown
  end
  it "cas command, no item" do
    @mc_client.cas("key12","w","5","CAS_Data".bytesize,690,"CAS_MainData").must_equal "NOT_FOUND"
    @mc_client.shutdown
  end
  it "Purge expired keys" do
    @mc_client.set("key13","w","1","MainData13".bytesize,"MainData13").must_equal "STORED"
    @mc_client.set("key14","w","4","MainData14".bytesize,"MainData14").must_equal "STORED"
    @mc_client.set("key15","w","2","MainData15".bytesize,"MainData15").must_equal "STORED"
    @mc_client.set("key16","w","3","MainData16".bytesize,"MainData16").must_equal "STORED"
    @mc_client.set("key17","w","20","MainData17".bytesize,"MainData17").must_equal "STORED"
    sleep(5)
    @mc_client.get("key13 key14 key15 key16 key17").must_equal "MainData17"
    @mc_client.shutdown
  end
end
