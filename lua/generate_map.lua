<<
	local a = ...

	local terrain = {wesnoth.get_terrain(a.x1, a.y2), wesnoth.get_terrain(a.x2, a.y2)}

	local location = { HexVec.new(a.x1, a.y1), HexVec.new(a.x2, a.y2) }

	local atkdir = location[2] - location[1]

	local keep_offset, map_center, map_dim = nil
	local dy = round(2 + map_size/3)

	if atkdir[1] == 0 then
		keep_offset = HexVec.new(round(1 + 4/3*map_size), dy)
		map_center = (adjacent_offset[4] * map_size) + keep_offset
		map_dim = HexVec.new(2*keep_offset.x - 1, 2*map_center.y -1)
	else
		keep_offset = HexVec.new( round(dy/0.866), dy)
		map_center = (adjacent_offset[3] * map_size) + keep_offset
		map_dim = HexVec.new(map_center.x*2-1, dy*2-1 + map_size)
	end

	-- needs map_dim
	local seed = map_dim[1] * 8363 * map_dim[2] + map_dim[2] * 91
	local seed_store = HexVecSet.new()

	local function ran(v)
		if seed_store[v] == nil then
			seed_store[v] = seed * (v[1] * 7369 + v[2])
		end
		seed_store[v] = (seed_store[v] * 1103515245 + 12345) % 2147483648
		return seed_store[v]/2147483648
	end

	local keep = { map_center - atkdir * map_size, map_center + atkdir * map_size }

	local surrounding_terrain = HexVecSet.new()
	local local2global = HexVecSet.new()
	local global2local = HexVecSet.new()
	for i = 1,2 do
		for j = 1,6 do
			local u = keep[i] + keep_conn[j]
			local v = location[i] + adjacent_offset[j]
			global2local[v] = u
			local2global[u] = v
			surrounding_terrain[u] = Terrain.new(wesnoth.get_terrain(v.x, v.y))
		end
	end

	local map = Map.new(map_dim)
	for x = 0, map.x do
		for y = 0, map.y do
			local min_dis = 4 * map_size
			for u, terrain in surrounding_terrain() do
				local dis = ( HexVec.new(x, y) - u ).length
				if dis <= min_dis then
					map(x, y, terrain:base(1))
					min_dis = dis
				end
			end
		end
	end

	for u, terrain in surrounding_terrain() do
		local v = local2global[u]
		palette = {}
		for tile in adjacent_tiles(v) do
			-- analyse palette
			local t = Terrain.new(wesnoth.get_terrain(tile.x, tile.y))
			palette[#palette + 1] = t:code(ran(v))
		end
		for i,t in pairs(palette) do print(i, t) end
		for i = 1, math.ceil(ran(v) * max_num_feature / 2) + max_num_feature / 2 do
			local f = HexVecSet.new()
			local t = palette[ran_int(ran(v), #palette)]
			local start = u + random_position(ran(v), map_size)
			local bdc = {}
			for i = 1,3 do bdc[i] = ran(v) * 6 end
			local corr = correlation(bdc[1], bdc[2], bdc[3])
			local length = round(ran(v) * max_feature_length)
			f[start] = t
			local last_dir = nil
			while #f < length do
				local c,C = {},0
				for i = 1,6 do
					c[i] = corr(i, last_dir)
					C = C + c[i]
				end
				local r = ran(v) * C
				for i = 1,6 do
					r = r - c[i]
					if r <= 0 then
						last_dir = i
						break
					end
				end
				repeat
					start = start + adjacent_offset[last_dir]
				until f[start] == nil
				f[start] = t
			end
			for v in f() do map[v] = t end
		end

		local kt,ct = terrain:keep_and_castle(ran(v))
		map[u] = kt
		for c in adjacent_tiles(u) do
			map[c] = ct
		end
	end

	wesnoth.set_variable("local_map", tostring(map))
	wesnoth.set_variable("GN_ATTACKER_X", keep[1].x)
	wesnoth.set_variable("GN_ATTACKER_Y", keep[1].y)
	wesnoth.set_variable("GN_DEFENDER_X", keep[2].x)
	wesnoth.set_variable("GN_DEFENDER_Y", keep[2].y)
>>

