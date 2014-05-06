require 'spec_helper'

TEST           = "test"
DEFAULT_EXPIRY = 600

describe 'SirCachealot Ram Cache and basic support' do

  it 'should be configurable' do

    Sir.configure do |config|
      config[:mode]           = :ram_cache
      config[:default_expiry] = DEFAULT_EXPIRY
      config[:debug]          = true
      config[:options]        = {}
    end

    (Sir.config(:default_expiry) == DEFAULT_EXPIRY && Sir.config(:mode) == :ram_cache).should == true

  end

  it 'should indicate that it is able' do
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
    Sir.length.should == 1
  end


  it 'should be able to list all keys' do
    x = Sir.keys.each do |k|
      Sir.debug("#{k}")
    end

    x[0].should == :test

  end


  it 'should sweep() correctly' do

    Sir.nuke

    Sir.put(:clean, TEST, 0)
    Sir.put(:mog, 1231231231, nil)
    Sir.sweep
    Sir.length.should == 1

  end

  it 'should sweep(true) correctly' do

    Sir.nuke

    Sir.put(:clean, TEST, 0)
    Sir.put(:mog, 1231231231, nil)
    Sir.sweep(true)
    Sir.length.should == 0

  end

  it 'should dump() correctly' do
    Sir.put(:dump, TEST)
    Sir.dump
  end

  it 'should accept a nil-expiry key' do
    Sir.put(:test_nil, TEST, nil).should == TEST
  end

  it 'should not expire a nil-expiry key' do
    Sir.get(:test_nil).should == TEST
  end

  it 'should delete a key if specified' do
    Sir.put(:delete_me, TEST)
    Sir.kill(:delete_me).should == true
    Sir.get(:delete_me).should == nil
  end

  it 'should return the same named key that it was given in event of a miss' do
    key = :adadadadad
    res = nil
    Sir.get(key) do |k|
      res = k
    end
    res.should == key
  end


end
