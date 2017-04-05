require 'spec_helper'
require 'redis'

TEST = "test"
TESTADV = {foo: {bar: [:baz, :bon, :buy], shaz: {:me => :baby}}}

DEFAULT_EXPIRY = 600

redis_obj = Redis.new(:host => "127.0.0.1", :port => "6379")

describe "Redis Adapter (marshal mode)" do

  it 'should connect and configure to Redis correctly' do

    Sir.configure do |config|
      config[:default_expiry] = DEFAULT_EXPIRY
      config[:mode] = :redis_cache

      config[:backend] = Sir::Backends::RedisCache.new do |rds|
        rds[:redis_obj] = redis_obj
        rds[:serializer] = :marshal
      end

    end

  end

  it_behaves_like Sir

end

describe "Redis Adapter (json mode)" do

  it 'should connect and configure to Redis correctly' do

    Sir.configure do |config|
      config[:default_expiry] = DEFAULT_EXPIRY
      config[:mode] = :redis_cache

      config[:backend] = Sir::Backends::RedisCache.new do |rds|
        rds[:redis_obj] = redis_obj
        rds[:serializer] = :json
      end

    end

  end

  it_behaves_like Sir

end