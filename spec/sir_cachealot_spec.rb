require 'spec_helper'

TEST = "test"
DEFAULT_EXPIRY = 600

describe SirCachealot do

	it 'should be configurable' do

		Sir.configure do |config|
			config[:default_expiry] = DEFAULT_EXPIRY
			config["MODE"]          = :ram_cache
			config[:debug]          = true
		end

		(Sir.config(:default_expiry) == DEFAULT_EXPIRY && Sir.config("MODE") == :ram_cache).should == true

	end

	it 'should accept and return an arbitrary key' do

		(Integer(Sir.put(:test, TEST)) > 0 && Sir.get(:test) == TEST).should == true

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



end