require 'minitest/autorun'
require_relative '../lib/MemCached'
#the server needs to be running before the execution of this test
puts "MemCached Test-[host port]"
intro = $stdin.gets.chomp
host,port = intro.split(/ /)
describe "MemCachedClient test" do
  before do
    @mcClient = MemCacheClient.new(host,port)
  end
  it "set an item" do
    @mcClient.set("key1","w","0","MainData".bytesize,"MainData").must_equal "STORED"
    @mcClient.get("key1").must_equal "MainData"
    @mcClient.shutdown
  end
  it "try to add an item that already is stored" do
    @mcClient.set("key2","w","0","MainData".bytesize,"MainData")
    @mcClient.add("key2","w","0","Adding Data".bytesize,"Adding Data").must_equal "NOT_STORED"
    @mcClient.shutdown
  end
  it "add a new item" do
    @mcClient.add("key3","w","0","Adding Data".bytesize,"Adding Data").must_equal "STORED"
    @mcClient.get("key3").must_equal "Adding Data"
    @mcClient.shutdown
  end
  it "get the right value of an item stored" do
    @mcClient.set("keytest","w","0","MainData".bytesize,"MainData").must_equal "STORED"
    @mcClient.get("keytest").must_equal "MainData"
    @mcClient.shutdown
  end
  it "trying to get nonexistent key " do
    @mcClient.get("k").must_equal arr = []
    @mcClient.shutdown
  end
  it "replace an existing item" do
    @mcClient.set("key4","w","5","MainData".bytesize,"MainData").must_equal "STORED"
    @mcClient.replace("key4","w","5","replacedData".bytesize,"replacedData").must_equal "STORED"
    @mcClient.get("key4").must_equal "replacedData"
    @mcClient.shutdown
  end
  it "trying to replace a nonexistent item" do
    @mcClient.replace("key90","w","5","replacedData".bytesize,"replacedData").must_equal "NOT_STORED"
    @mcClient.shutdown
  end
  it "append to an existing key" do
    @mcClient.set("key5","w","5","Data".bytesize,"Data").must_equal "STORED"
    @mcClient.append("key5","-RightData".bytesize,"-RightData").must_equal "STORED"
    @mcClient.get("key5").must_equal "Data-RightData"
    @mcClient.shutdown
  end
  it "prepend to an existing key" do
    @mcClient.set("key6","w","5","Data".bytesize,"Data").must_equal "STORED"
    @mcClient.prepend("key6","LeftData-".bytesize,"LeftData-").must_equal "STORED"
    @mcClient.get("key6").must_equal "LeftData-Data"
    @mcClient.shutdown
  end
  it "append and prepend commands" do
    @mcClient.set("key7","w","5","MainData".bytesize,"MainData").must_equal "STORED"
    @mcClient.append("key7","-RightData".bytesize,"-RightData").must_equal "STORED"
    @mcClient.prepend("key7","LeftData-".bytesize,"LeftData-").must_equal "STORED"
    @mcClient.get("key7").must_equal "LeftData-MainData-RightData"
    @mcClient.shutdown
  end
  it "trying to append a nonexistent item" do
    @mcClient.append("key8","-RightData".bytesize,"-RightData").must_equal "NOT_STORED"
    @mcClient.shutdown
  end
  it "trying to prepend a nonexistent item" do
    @mcClient.prepend("key9","LeftData-".bytesize,"LeftData-").must_equal "NOT_STORED"
    @mcClient.shutdown
  end
  it "cas command, right situation" do
    @mcClient.set("key10","w","5","MainData".bytesize,"MainData").must_equal "STORED"
    cas_token = @mcClient.gets("key10").cas
    @mcClient.cas("key10","w","5","CAS_MainData".bytesize,cas_token,"CAS_MainData").must_equal "STORED"
    @mcClient.get("key10").must_equal "CAS_MainData"
    @mcClient.shutdown
  end
  it "cas command, wrong situation" do
    @mcClient.set("key11","w","5","MainData".bytesize,"MainData").must_equal "STORED"
    cas_token = @mcClient.gets("key11").cas
    @mcClient.set("key11","w","5","MainData".bytesize,"MainData").must_equal "STORED"
    @mcClient.cas("key11","w","5","CAS_Data".bytesize,cas_token,"CAS_Data").must_equal "EXISTS"
    @mcClient.shutdown
  end
  it "cas command, no item" do
    @mcClient.cas("key12","w","5","CAS_Data".bytesize,690,"CAS_MainData").must_equal "NOT_FOUND"
    @mcClient.shutdown
  end
  it "Purge expired keys" do
    @mcClient.set("key13","w","1","MainData13".bytesize,"MainData13").must_equal "STORED"
    @mcClient.set("key14","w","4","MainData14".bytesize,"MainData14").must_equal "STORED"
    @mcClient.set("key15","w","2","MainData15".bytesize,"MainData15").must_equal "STORED"
    @mcClient.set("key16","w","3","MainData16".bytesize,"MainData16").must_equal "STORED"
    @mcClient.set("key17","w","20","MainData17".bytesize,"MainData17").must_equal "STORED"
    sleep(5)
    @mcClient.get("key13 key14 key15 key16 key17").must_equal "MainData17"
    @mcClient.shutdown
  end
end
