# SirCachealot
![Sir Cachealot graphic](https://github.com/lyjia/sircachealot/blob/master/sircachealot.png?raw=true "Sir Cachealot graphic")

SirCachealot is a very simple memcache-like keystore, licensed under LGPLv3. It is built to be modular and present a consistent API.

Future plans for 1.0:
* Rails cache, Redis, and memcache storage modes.

## Installation

Add this line to your application's Gemfile:

    gem 'sir_cachealot'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sir_cachealot

## Usage

SirCachealot exposes a new module named `Sir`. This module is designed to be available globally in both Rails apps and vanilla Ruby scripts (don't forget `require 'sir_cachealot'`!)

**You can use SirCachealot immediately, using either:**

    Sir.put(keyname, value)
    Sir.put(keyname, value, expiry) # expiry can be relative or absolute time expressed in seconds (Fixnum) or a Time object.

`put()` will return the object you gave it. This is useful if you wish to use `get()`'s `yield` functionality.

If `config(:delete_on_nil) == true` and `value == nil`, `put()` will return `true` (because it deleted the key).

**You can retreive the value later, if it hasn't expired, with:**

    my_var = Sir.get(keyname) # for a shallow copy
    my_var = Sir.get(keyname, true) # for a deep copy (crude way, Marshal.load(Marshal.dump(obj)) )

or

    # A convenient way to rectify a cache miss!
    # put() returns the object you give it
    my_var = Sir.get(keyname) do 
        Sir.put(keyname, User.find_by_id(id))
    end

If the key does not exist, or if it has expired:
* `get()` returns `nil` if not given a block to execute.
* `get()` yields to code block, if one is supplied.

**To delete a cache entry, you can:**

	Sir.delete(key)

**If you want to clear the cache, you can:**

    Sir.clear

**If you want to sweep and purge all expired entries, you can:**

    Sir.clean

**There are a few configuration options available. You can configure SirCachealot with:**

    Sir.configure do |config|
        config[:default_expiry] = 3600 # default expiration timeout in seconds
        config[:mode]           = :ram_cache # cache storage mode. Currently only :ram_cache is supported. Others may be added at a later date.
        config[:debug]          = true|false # show some debug messages
        config[:annoy]          = true|false # show even more debug messages
		config[:delete_on_nil]  = true|false # auto-deletes stale cache entries on if value == nil
    end
    
*Note: Config keynames are always `.downcase.to_sym`!*

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Use of SirCachealot is permitted under the terms of [LGPLv3](http://www.gnu.org/licenses/lgpl-3.0.txt).
For more information see LICENSE.txt.