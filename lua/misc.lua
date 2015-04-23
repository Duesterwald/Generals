<<

	map_size = wesnoth.get_variable("GN_LOCAL_MAP_SIZE")

	global_map_size = {wesnoth.get_map_size()}

	hex_area = 3 * (map_size * map_size + map_size)

	max_num_feature =  hex_area * wesnoth.get_variable("GN_LOCAL_FEATURE_DENSITY") / 100

	max_feature_length = map_size * wesnoth.get_variable("GN_LOCAL_FEATURE_SIZE") / 100

	num_villages = hex_area * wesnoth.get_variable("GN_LOCAL_VILLAGE_DENSITY") / 1000

	keep_size = wesnoth.get_variable("GN_LOCAL_KEEP_SIZE")

	function round(x)
		return math.floor(x+0.5)
	end

	function ran_int(ran, n)
		ran = ran * n
		n = math.ceil(ran)
		if n-ran == 0 then error("Random bits depleted") end
		return n, n - ran
	end

	function ran_element(ran, array)
		local n = #array
		n,ran = ran_int(ran, n)
		return array[n], ran
	end

	function weighted_key(ran, array)
		local totalweight = 0
		for i, w in ipairs(array) do totalweight = totalweight + w end
		local r = ran * totalweight
		for i, wi in ipairs(array) do
			r = r - wi
			if r < 0 then return i, -r/wi end
		end
		return nil, ran
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
		local corr_matrix = {}
		for last_dir = 1, 6 do
			corr_matrix[last_dir] = {}
			local sum = 0
			for direction = 1, 6 do
				if ( direction - last_dir + 6 ) % 6 == 3 then corr_matrix[last_dir][direction] = 0
				else corr_matrix[last_dir][direction] = sawtooth(bias, bias_deviation, direction) *
					sawtooth(last_dir, correlation_strength, direction)
				end
				sum = sum + corr_matrix[last_dir][direction]
			end
			corr_matrix[last_dir].sum = sum
		end

		corr_matrix[0] = {}
		local sum = 0
		for direction = 1, 6 do
			corr_matrix[0][direction] = sawtooth(bias, bias_deviation, direction)
			sum = sum + corr_matrix[0][direction]
		end
		corr_matrix[0].sum = sum

		return corr_matrix
	end

	print("misc.lua loaded.")
>>
