require 'spec_helper'

TEST = "test"
DEFAULT_EXPIRY = 600

describe 'Ram Cache (mashal serializer)' do

  it 'should be configurable' do

    Sir.configure do |config|
      config[:backend] = Sir::Backends::RamCache.new
      config[:default_expiry] = DEFAULT_EXPIRY
      config[:serializer] = :marshal
    end

    (Sir.config(:default_expiry) == DEFAULT_EXPIRY && Sir.config(:mode) == :ram_cache).should == true

  end

  it_behaves_like Sir

end


describe 'Ram Cache (json serializer)' do

  it 'should be configurable' do

    Sir.configure do |config|
      config[:backend] = Sir::Backends::RamCache.new
      config[:default_expiry] = DEFAULT_EXPIRY
      config[:serializer] = :json
    end

    (Sir.config(:default_expiry) == DEFAULT_EXPIRY && Sir.config(:mode) == :ram_cache).should == true

  end

  it_behaves_like Sir

end