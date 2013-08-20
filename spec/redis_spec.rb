require 'spec_helper'
require 'redis'

TEST           = "test"
DEFAULT_EXPIRY = 600

redis_obj = Redis.new(:path => "/tmp/redis.sock")

describe "SirCachealot Redis support" do
	
	it 'should connect and configure correctly' do
		Sir.configure do |config|
			config[:default_expiry] = DEFAULT_EXPIRY
			config["MODE"]          = :redis_cache
			config[:debug]          = true
			config[:use_redis_obj] = redis_obj
		end
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

		Sir.size?.should == 1

	end



end