require 'spec_helper'
require 'redis'

TEST           = "test"
DEFAULT_EXPIRY = 600

redis_obj = Redis.new(:host => "127.0.0.1", :port => "6379")

describe "SirCachealot Redis support" do

  it 'should connect and configure to Redis correctly' do

    opts             = Sir::Backends::RedisCache::DEFAULTS
    opts[:redis_obj] = redis_obj

    Sir.configure do |config|
      config[:default_expiry] = DEFAULT_EXPIRY
      config[:mode]           = :redis_cache
      config[:debug]          = true
      config[:options]        = opts
    end

  end

  it 'should respond to able?' do
    Sir.able?.should == true
  end

  it 'should return the key that is put into it' do
    Sir.put(:test, TEST).should == TEST
  end

  it 'should return an arbitrary key' do
    (Sir.get(:test) == TEST).should == true
  end

  it 'should yield when given a block and a key that does not exist' do
    (Sir.get(:asdoiajdoaijdaodijaodiajdoaidjaodijaodij) { 5 }).should == 5
  end

  it 'should return nil when not given a block and a key that does not exist' do
    (Sir.get(:asdoiajdoaijdaodijaodiajdoaidjaodijaodij)).should == nil
  end

  it 'should immediately expire a 0-expiry key' do
    Sir.put(:expire, TEST, 0)
    sleep(1)

    Sir.get(:expire).should == nil
  end

  it 'should report its size correctly' do

    Sir.size?.should == :not_possible

  end

end