require 'spec_helper'

TEST           = "test"
DEFAULT_EXPIRY = 600

describe SirCachealot do

	it 'should be configurable' do

		Sir.configure do |config|
			config[:default_expiry] = DEFAULT_EXPIRY
			config["MODE"]          = :ram_cache
			config[:debug]          = true
		end

		(Sir.config(:default_expiry) == DEFAULT_EXPIRY && Sir.config(:mode) == :ram_cache).should == true

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

	it 'should clean() correctly' do

		Sir.clear

		Sir.put(:clean, TEST, 0)
		Sir.clean

		Sir.size?.should == 0

	end

	it 'should dump() correctly' do
		Sir.put(:dump, TEST)
		Sir.dump
	end

	it 'should accept a nil-expiry key' do
		Sir.put(:test_nil, TEST).should == TEST
	end

	it 'should not expire a nil-expiry key' do
		Sir.get(:test_nil).should == TEST
	end

	it 'should auto-delete a key when fed a nil' do
		Sir.put(:test_nil, nil).should == true
	end

	it 'should delete a key if specified' do
		Sir.put(:delete_me, TEST)
		Sir.delete(:delete_me).should == true
	end

	it 'should return a shallow copy by default' do
		hash = { :a => { :aa => 0 } }
		Sir.put(:shallow_copy, hash)

		newhash = Sir.get(:shallow_copy)

		newhash[:a][:aa] = 1

		(hash[:a][:aa]).should == newhash[:a][:aa]

	end

	it 'should return a deep copy when asked' do
		hash = { :a => { :aa => "0" } }
		Sir.put(:deep_copy, hash)

		newhash = Sir.get(:deep_copy, true)

		newhash[:a][:aa] = "1"

		(hash[:a][:aa]).should_not == newhash[:a][:aa]

	end
	
end
