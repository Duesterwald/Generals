<<

	map_size = wesnoth.get_variable("GN_LOCAL_MAP_SIZE")

	max_num_feature = 3 * (map_size * map_size + map_size) * wesnoth.get_variable("GN_LOCAL_FEATURE_DENSITY") / 100

	max_feature_length = map_size * wesnoth.get_variable("GN_LOCAL_FEATURE_SIZE") / 100

	function round(x)
		return math.floor(x+0.5)
	end

	function ran_int(ran, n)
		local ran = ran * n
		local i = math.ceil(ran)
		return i, i - ran
	end

	function sawtooth(maximum, deviation, direction)
			if maximum == nil or deviation == nil then return 1 end
			if deviation < 0 then
				direction = (direction + 3) % 6
				deviation = -deviation
			end
			local x = math.abs(direction - maximum)
			return math.max(deviation - x, deviation / 12, x + deviation - 6)
	end

	function correlation(bias, bias_deviation, correlation_strength)
		return function(direction, last_dir)
			if last_dir == nil then return sawtooth(bias, bias_deviation, direction) end
			if ( direction - last_dir + 6 ) % 6 == 3 then return 0 end
			return sawtooth(bias, bias_deviation, direction) * sawtooth(last_dir, correlation_strength, direction)
		end
	end

	print("misc.lua loaded.")
>>
