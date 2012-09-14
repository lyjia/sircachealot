require "sir_cachealot/version"

module SirCachealot

	class SirCachealot

		@@ram_cache = { }

		@@configuration = {
				mode: :ram_cache
		}

		def self.config(key = nil, value = nil)

			key = key.downcase.to_sym unless key.nil?

			if !key.nil? && !value.nil?
				@@configuration[key] = value
				return value
			elsif !key.nil? && value.nil?
				return @@configuration[key]
			elsif key.nil? && value.nil?
				yield(@@configuration)

				#normalize keynames
				@@configuration.keys.each do |k|
					
					knew = k.downcase.to_sym

					unless knew == k
						@@configuration[knew] = @@configuration[k]
						@@configuration.delete(k)
					end

				end

			end

		end

		def self.get(key)

			case config(:mode)
				when :ram_cache

					if x = @@ram_cache[key]

						if x[:expiry] > Time.now
							return x[:value]
						else
							# cache entry is stale
							Mog.debug("Cache entry #{key} expired at #{x[:expiry]}. Deleting...")
							@@ram_cache.delete(key)
							return nil
						end

					else
						return nil
					end

				else
					puke
			end

		end

		def self.put(key, value, expiry = (Time.now + 1.hour))

			case config(:mode)
				when :ram_cache

					@@ram_cache[key]          ||= { }
					@@ram_cache[key][:value]  = value
					@@ram_cache[key][:expiry] = expiry

				else
					puke
			end


		end

		def self.size?

			case config(:mode)
				when :ram_cache
					return @@ram_cache.count
				else
					puke
			end

		end

		def self.dump

			case config(:mode)
				when :ram_cache
					@@ram_cache.each do |k, v|
						puts("%-20s %-20s %20s" % [k, v[:value].class, v[:expiry]])
					end
				else
					puke
			end


			return nil

		end

		def self.clear

			case config(:mode)
				when :ram_cache
					@@ram_cache = { }
				else
					puke
			end

		end

		def self.clean

			case config(:mode)
				when :ram_cache
					@@ram_cache.each_key do |k|
						if @@ram_cache[k][:expiry] < Time.now
							Mog.debug("Cleaned #{k}") if Mog
							@@ram_cache[k].delete
						end
					end
				else
					puke
			end

		end

		def self.puke
			raise("SirCachealot: invalid :mode")
		end

	end

end
