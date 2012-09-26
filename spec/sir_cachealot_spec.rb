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



end
