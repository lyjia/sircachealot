require 'rspec'
require 'sir'

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end

shared_examples_for Sir do

  it 'should annihilate everything correctly and return the correct size' do
    Sir.nuke
    Sir.length.should == 0
  end

  it 'should respond to able?' do
    Sir.able?.should == true
  end

  it 'should return the key that is put into it' do
    Sir.put(:test, TEST).should == TEST
  end

  it 'should return an arbitrary key' do
    Sir.get(:test).should == TEST
  end

  it 'should be able to list all keys' do
    x = Sir.keys.each do |k|
      Sir.debug("#{k}")
    end

    x[0].should == :test

  end

  it 'should support get() with blocks (with key param)' do
    x = Sir.get(:test2) do |key|
      Sir.put(key, TEST)
    end
  end

  it 'should support get() with blocks (without key param, <= v0.5-style)' do
    x = Sir.get(:test3) do
      Sir.put(:test3, TEST)
    end
  end

  it 'should yield when given a block and a key that does not exist' do
    (Sir.get(:asdoiajdoaijdaodijaodiajdoaidjaodijaodij) { 5 }).should == 5
  end

  it 'should return nil when not given a block and a key that does not exist' do
    (Sir.get(:asdoiajdoaijdaodijaodiajdoaidjaodijaodij)).should == nil
  end

  it 'should be able to delete a key' do
    k = :alasdiauhdaiudhai
    Sir.put(k, "test")
    Sir.kill(k)
    Sir.get(k).should == nil
  end

  it 'should immediately expire a 0-expiry key' do
    Sir.put(:expire, TEST, 0)
    sleep(1)

    Sir.get(:expire).should == nil
  end


end