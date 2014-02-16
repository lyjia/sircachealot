# SirCachealot
![Sir Cachealot graphic](https://github.com/lyjia/sircachealot/blob/master/sircachealot.png?raw=true "Sir Cachealot graphic")

SirCachealot is an easy-to-use, pluggable key-value store, available under the 2-clause BSD license. It is built for:

* Swappable, modular backends. Cache server down? Swap another one in and keep chuggin'. Currently supports Redis and an in-memory store.
* Shared memory between processes. Multi-process environments (such as in Passenger) make shared state difficult.
* Unified API supporting a selected, shared subset of each backend's features.
* Easily and seamlessly deal with cache misses.
* Lets you cache stuff the Ruby way!

Here's an example usage, which caches a user object to avoid fetching it from the database:

    def login(id, password_hash)

        user = Sir.get(keyname) do |key|               #Doesn't execute the block is key is found
            Sir.put(key, User.find_by_id(id), 1.day)   #Cache miss! So let's fetch the User and store it for a day
        end                                                 (note: 1.day comes from Rails, not included)

        # your code here
        user.authenticate?(password_hash)              #returns true if match, false is not

    end

Roadmap for 1.0:
* More storage backends: RailsCache, Postgres HSTORE, Mysql memtable, memcache, internal
* Add redis incr/decr and extra datatypes (emulate features on ramcache if necessary)
* Explore clustering applications
* Add convenience methods to ActiveRecord

## Installation

Add this line to your application's Gemfile:

    gem 'sir_cachealot'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sir_cachealot

## Usage

SirCachealot exposes a new module named `Sir`. This module is designed to be available globally in both Rails apps and vanilla Ruby scripts (don't forget `require 'sir_cachealot'`!)

This section is a quick tour through some of SirCachealot's best features. For a comprehensive API reference, please refer to the comments in `Sir::Backends::Base`.

**You can use SirCachealot immediately, using either:**

    Sir.put(keyname, value)
    Sir.put(keyname, value, expiry) # expiry can be relative or absolute time expressed in seconds (Fixnum) or a Time object.

`put()` will return the object you gave it. This is useful if you wish to use `get()`'s `yield` functionality.

If `config(:delete_on_nil) == true` and `value == nil`, `put()` will return `true` (because it deleted the key).

**You can retreive the value later, if it hasn't expired, with:**

    my_var = Sir.get(keyname)

or

    # A convenient way to rectify a cache miss!
    # put() returns the object you give it
    my_var = Sir.get(keyname) do |key|
        Sir.put(key, User.find_by_id(id))
    end

If the key does not exist, or if it has expired:

* `get()` returns `nil` if not given a block to execute.
* `get()` yields to code block, if one is supplied.

**To delete a cache entry, you can:**

	Sir.kill(key)

**If you want to clear the cache, you can:**

    Sir.nuke

**If you want to sweep and purge all expired entries, you can:**

    Sir.sweep

**There are a few configuration options available. You can configure SirCachealot with:**

    cache_opts = Sir::Backends::RamCache::DEFAULTS #Change RamCache to RedisCache for redis

    Sir.configure do |config|
        config[:default_expiry] = 3600 # default expiration timeout in seconds
        config[:mode]           = :ram_cache # cache storage mode. Currently: :ram_cache, :redis_cache
        config[:debug]          = true|false # show some debug messages
        config[:annoy]          = true|false # show even more debug messages
        config[:options]        = cache_opts # optional, depending on backend
    end
    
Note: Backends may have additional configuration parameters that need to be satisfied. The default configuration can be retreived from the `DEFAULTS` constant in the backend class, as shown above. These values may then be modified and passed back to `Sir.configure()`

## API Reference

See `Sir::Backends::Base`

## Available Backends

### RAM Cache (for testing)
The RAM Cache stores cache entries in a Ruby hash, and is the default cache store that SirCachealot will use if left unconfigured.

RAM Cache does not support automatic expiration, and so it must be periodically #swept(). RAM Cache's thread safety depends on your interpreter: 'green thread' implementations are safe, while true multi-threaded environments (such as JRuby) remain untested at this time.

This backend module is intentionally left simple, and is of limited usefulness. It is designed to be an example for implementing additional backends, and to satisfy basic turn-key functionality.

#### Configuration
Note that #configure is not necessary if you wish to use RAM cache with its default settings.

    Sir.configure do |config|
        config[:default_expiry] = 3600
        config[:mode]           = :ram_cache
    end

### Redis Cache
Redis cache supports a subset of full Redis functionality.

#### Configuration

    redis_obj = Redis.new(:path => "/tmp/redis.sock")

    cache_opts = Sir::Backends::RedisCache::DEFAULTS
    cache_opts[:redis_obj] = redis_obj                   #supply a preconfigured Redis instance

    Sir.configure do |config|
        config[:default_expiry] = 3600
        config[:mode]           = :redis_cache
        config[:options]        = cache_opts
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Use of SirCachealot is permitted under the terms of the [2-clause BSD License](http://directory.fsf.org/wiki?title=License:FreeBSD).
For more information see LICENSE.txt.